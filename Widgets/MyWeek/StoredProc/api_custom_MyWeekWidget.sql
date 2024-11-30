SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[api_custom_MyWeekWidget]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[api_custom_MyWeekWidget] AS' 
END
GO

-- =============================================
-- api_custom_MyWeekWidget
-- =============================================
-- Description:		Custom Widget SP for returning a user's upcoming week's events
-- Last Modified:	11/30/2024
-- Stephan Swinford
-- Updates:
--		11/30 - Initial
-- =============================================

CREATE PROCEDURE [dbo].[api_custom_MyWeekWidget]
              @DomainID INT
              ,@Username nvarchar(75) = null
			  ,@UserGUID nvarchar(50) = null
			  ,@DaysAhead int = 7
AS
BEGIN

	DECLARE @HouseholdID int;
	DECLARE @GlobalCongregationID int;

	-- Set the current user's Household ID. --
	-- Must pass only the username or only the user GUID. Passing both will result in NULL --
	SET @HouseholdID = (SELECT TOP 1 (C.Household_ID) FROM Contacts C
		LEFT JOIN dp_Users U ON U.User_Name=@Username
		LEFT JOIN dp_Users U2 ON U2.User_GUID=@UserGUID
		WHERE (C.Contact_ID=U.Contact_ID AND @UserGUID IS NULL)
		OR (C.Contact_ID=U2.Contact_ID AND @Username IS NULL));

	-- Set the Global Congregation ID for checking "All Campuses" events --
	SET @GlobalCongregationID = (SELECT TOP 1 (CS.Value) FROM dp_Configuration_Settings CS
		WHERE CS.Domain_ID = @DomainID
		AND CS.Application_Code = 'COMMON'
		AND CS.Key_Name = 'GlobalCongregationID');

	-- If a Household ID was selected, continue --
	IF @HouseholdID > 0 BEGIN

		-- Create a temp table for storing Events. We'll select distinct Events later --
		CREATE TABLE #EventsTemp (
			Event_ID int, 
			Event_Title nvarchar(50), 
			Event_Start_Date datetime,
			DayNumber int,
			Participant nvarchar(50), 
			Role_Title nvarchar(50)
		);

		-- Insert Event Participants --
		INSERT INTO #EventsTemp
		SELECT
			E.Event_ID
			,E.Event_Title
			,E.Event_Start_Date
			,DATEDIFF(day,GetDate(),E.Event_Start_Date) AS DayNumber
			,ISNULL(C.Nickname,C.First_Name) AS [Participant]
			,null
		FROM Events E
			JOIN Event_Participants EP ON EP.Event_ID=E.Event_ID
			JOIN Contacts C ON C.Participant_Record=EP.Participant_ID
			JOIN Households H ON H.Household_ID=C.Household_ID
		WHERE
			C.Household_ID = @HouseholdID
			AND E.Event_Start_Date BETWEEN GetDate() AND GetDate()+@DaysAhead
			AND E.Cancelled=0
			AND EP.Participation_Status_ID IN (2,3,4)
			AND NOT EXISTS (SELECT SP.Schedule_Participant_ID FROM Scheduled_Participants SP
				JOIN Schedule_Roles SR ON SR.Schedule_Role_ID = SP.Schedule_Role_ID
				JOIN Schedules S ON S.Schedule_ID = SR.Schedule_ID
				WHERE SP.Participant_ID = EP.Participant_ID
				AND SP.Declined_and_Hidden = 0
				AND S.Event_ID = E.Event_ID)
		ORDER BY
			E.Event_Start_Date
			,C.Household_Position_ID;

		-- Insert Group Events --
		INSERT INTO #EventsTemp
		SELECT
			E.Event_ID
			,E.Event_Title
			,E.Event_Start_Date
			,DATEDIFF(day,GetDate(),E.Event_Start_Date) AS DayNumber
			,ISNULL(C.Nickname,C.First_Name) AS [Participant]
			,null
		FROM Events E
			JOIN (SELECT DISTINCT Event_ID, Group_ID FROM Event_Rooms) ER ON ER.Event_ID = E.Event_ID
			JOIN Groups G ON G.Group_ID=ER.Group_ID
			JOIN Group_Participants GP ON GP.Group_ID=G.Group_ID
			JOIN Contacts C ON C.Participant_Record=GP.Participant_ID
			JOIN Households H ON H.Household_ID=C.Household_ID
		WHERE
			C.Household_ID = @HouseholdID
			AND E.Event_Start_Date BETWEEN GetDate() AND GetDate()+@DaysAhead
			AND ISNULL(GP.End_Date,GetDate())>=GetDate()
			AND E.Cancelled=0
			AND (E.Congregation_ID=H.Congregation_ID OR E.Congregation_ID=@GlobalCongregationID)
			AND NOT EXISTS(SELECT S.Schedule_ID FROM Schedules S
				WHERE S.Event_ID=E.Event_ID
				AND S.Group_ID=G.Group_ID)
		ORDER BY
			E.Event_Start_Date
			,C.Household_Position_ID;

		-- Insert Volunteer Schedules --
		INSERT INTO #EventsTemp
		SELECT
			E.Event_ID
			,E.Event_Title
			,DATETIMEFROMPARTS(YEAR(E.Event_Start_Date),MONTH(E.Event_Start_Date),DAY(E.Event_Start_Date),
				DATEPART(HOUR,SR.Start_Time),DATEPART(MINUTE,SR.Start_Time),0,0) AS Event_Start_Date
			,DATEDIFF(day,GetDate(),E.Event_Start_Date) AS DayNumber
			,ISNULL(C.Nickname,C.First_Name) AS [Participant]
			,GR.Role_Title
		FROM Events E
			JOIN Schedules S ON S.Event_ID = E.Event_ID
			JOIN Schedule_Roles SR ON SR.Schedule_ID = S.Schedule_ID
			JOIN Scheduled_Participants SP ON SP.Schedule_Role_ID = SR.Schedule_Role_ID
			JOIN Group_Roles GR ON GR.Group_Role_ID = SR.Group_Role_ID
			JOIN Contacts C ON C.Participant_Record=SP.Participant_ID
			JOIN Households H ON H.Household_ID=C.Household_ID
		WHERE
			C.Household_ID = @HouseholdID
			AND E.Event_Start_Date BETWEEN GetDate() AND GetDate()+@DaysAhead
			AND E.Cancelled=0
			AND (E.Congregation_ID=H.Congregation_ID OR E.Congregation_ID=@GlobalCongregationID)
		ORDER BY
			E.Event_Start_Date
			,C.Household_Position_ID;

		-- Return DataSet1 - Upcoming Dates for Headers --
		WITH DateSequence AS (
			SELECT GetDate() AS DateValue, 0 as DayNumber
			UNION ALL
			SELECT DATEADD(DAY, 1, DateValue), DayNumber+1
			FROM DateSequence
			WHERE DATEADD(DAY, 1, DateValue) < DATEADD(DAY, @DaysAhead, GetDate())
		)
		SELECT FORMAT(DateValue, 'dddd, MMM dd') AS FormattedDate,DayNumber
		FROM DateSequence
		OPTION (MAXRECURSION 0);

		-- Return DataSet2 - Upcoming Events --
		SELECT DISTINCT
			Event_ID
			,ISNULL(Role_Title,Event_Title) AS [Event_Title]
			,FORMAT(Event_Start_Date, 'h:mm tt') AS [Event_Start_Date]
			,DayNumber
			,STRING_AGG(Participant,', ') AS [Participants]
		FROM #EventsTemp
		GROUP BY 
			Event_ID
			,Event_Title
			,Role_Title
			,Event_Start_Date
			,DayNumber
		ORDER BY
			DayNumber
			,Event_Start_Date DESC;

		DROP TABLE #EventsTemp;

	-- END IF SECTION --
	END

END



-- ========================================================================================
-- SP MetaData Install
-- ========================================================================================
DECLARE @spName nvarchar(128) = 'api_custom_MyWeekWidget'
DECLARE @spDescription nvarchar(500) = 'Custom Widget SP for returning a user's upcoming week's events'

IF NOT EXISTS (SELECT API_Procedure_ID FROM dp_API_Procedures WHERE Procedure_Name = @spName)
BEGIN
	INSERT INTO dp_API_Procedures
	(Procedure_Name, Description)
	VALUES
	(@spName, @spDescription)	
END


DECLARE @AdminRoleID INT = (SELECT Role_ID FROM dp_Roles WHERE Role_Name='Administrators')
IF NOT EXISTS (SELECT * FROM dp_Role_API_Procedures RP INNER JOIN dp_API_Procedures AP ON AP.API_Procedure_ID = RP.API_Procedure_ID WHERE AP.Procedure_Name = @spName AND RP.Role_ID=@AdminRoleID)
BEGIN
	INSERT INTO dp_Role_API_Procedures
	(Domain_ID,  API_Procedure_ID, Role_ID)
	VALUES
	(1, (SELECT API_Procedure_ID FROM dp_API_Procedures WHERE Procedure_Name = @spName), @AdminRoleID)
END
GO
-- ========================================================================================