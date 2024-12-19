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
-- Last Modified:	12/19/2024
-- Stephan Swinford
-- Updates:
--		12/19 - Initial
-- =============================================

CREATE PROCEDURE [dbo].[api_custom_MyWeekWidget]
              @DomainID INT
              ,@Username nvarchar(75) = null
			  ,@UserGUID nvarchar(50) = null
			  ,@DaysAhead int = 7 -- Default number of days of events to get
			  ,@EventTypeId int = 7 -- Default Event Type ID for "highlighted" events
			  ,@FeaturedEvents int = 1 -- Include featured events
AS
BEGIN

	DECLARE @HouseholdID int;
	DECLARE @HouseholdCongregationID int;
	DECLARE @GlobalCongregationID int;
	-- Get the server's current timezone offset in minutes --
	-- We'll use this to return datetimes as UTC, which Liquid will convert to the user's local time --
	DECLARE @CurrentOffset AS INT;
		SET @CurrentOffset = DATEPART(TZOFFSET, SYSDATETIMEOFFSET());

	-- Set the current user's Household ID. --
	-- Can accept either the logged in username or a User_GUID, but will fall back to username if both are provided --
	SET @HouseholdID = (SELECT TOP 1 (C.Household_ID) FROM Contacts C
		LEFT JOIN dp_Users U ON U.User_Name=@Username
		LEFT JOIN dp_Users U2 ON U2.User_GUID=@UserGUID
		WHERE (C.Contact_ID=U.Contact_ID)
		OR (C.Contact_ID=U2.Contact_ID AND @Username IS NULL));

	-- If a Household ID was selected, continue --
	IF @HouseholdID > 0 BEGIN

		-- Set the current user's Household Congregation ID. --
		SET @HouseholdCongregationID = (SELECT TOP 1 (H.Congregation_ID) FROM Households H
			WHERE H.Household_ID = @HouseholdID);

		-- Set the Global Congregation ID for checking "All Campuses" events --
		SET @GlobalCongregationID = (SELECT TOP 1 (CS.Value) FROM dp_Configuration_Settings CS
			WHERE CS.Domain_ID = @DomainID
			AND CS.Application_Code = 'COMMON'
			AND CS.Key_Name = 'GlobalCongregationID');

		-- Create a temp table for storing Events. We'll select distinct Events later --
		CREATE TABLE #EventsTemp (
			Event_ID int
			,Event_Title nvarchar(100)
			,Event_Start_Date datetime
			,Event_End_Date datetime
			,DayNumber int
			,Participant nvarchar(100)
			,Role_Title nvarchar(50)
			,Event_Type nvarchar(50)
		);

		-- Insert Event Participants --
		INSERT INTO #EventsTemp
		SELECT
			E.Event_ID
			,E.Event_Title
			,E.Event_Start_Date
			,E.Event_End_Date
			,DATEDIFF(day,GetDate(),E.Event_Start_Date) AS DayNumber
			,ISNULL(C.Nickname,C.First_Name) AS [Participant]
			,null
			,'participant-event'
		FROM Events E
			JOIN Event_Participants EP ON EP.Event_ID=E.Event_ID
			JOIN Contacts C ON C.Participant_Record=EP.Participant_ID
			JOIN Households H ON H.Household_ID=C.Household_ID
		WHERE
			C.Household_ID = @HouseholdID
			AND E.Event_End_Date BETWEEN GetDate() AND GetDate()+@DaysAhead
			AND E.Cancelled=0
			AND EP.Participation_Status_ID IN (2,3,4)
			-- Exclude EP if they were added as a Group Participant --
			AND EP.Group_Participant_ID IS NULL
			-- Exclude EP if they were added as part of a Volunteer Schedule --
			AND NOT EXISTS (SELECT SP.Schedule_Participant_ID FROM Scheduled_Participants SP
				JOIN Schedule_Roles SR ON SR.Schedule_Role_ID = SP.Schedule_Role_ID
				JOIN Schedules S ON S.Schedule_ID = SR.Schedule_ID
				WHERE SP.Participant_ID = EP.Participant_ID
				AND SP.Declined_and_Hidden = 0
				AND S.Event_ID = E.Event_ID)
		ORDER BY
			E.Event_Start_Date
			,C.Household_Position_ID
			,C.Nickname;

		-- Insert Group Events --
		INSERT INTO #EventsTemp
		SELECT
			E.Event_ID
			,E.Event_Title
			,E.Event_Start_Date
			,E.Event_End_Date
			,DATEDIFF(day,GetDate(),E.Event_Start_Date) AS DayNumber
			,ISNULL(C.Nickname,C.First_Name) AS [Participant]
			,null
			,'group-event'
		FROM Events E
			JOIN (SELECT DISTINCT Event_ID, Group_ID FROM Event_Rooms) ER ON ER.Event_ID = E.Event_ID
			JOIN Groups G ON G.Group_ID=ER.Group_ID
			JOIN Group_Participants GP ON GP.Group_ID=G.Group_ID
			JOIN Contacts C ON C.Participant_Record=GP.Participant_ID
			JOIN Households H ON H.Household_ID=C.Household_ID
		WHERE
			C.Household_ID = @HouseholdID
			AND E.Event_End_Date BETWEEN GetDate() AND GetDate()+@DaysAhead
			AND ISNULL(GP.End_Date,GetDate())>=GetDate()
			AND E.Cancelled=0
			AND (E.Congregation_ID=H.Congregation_ID OR E.Congregation_ID=@GlobalCongregationID)
			-- Exclude if they are already an Event Participant --
			AND NOT EXISTS(SELECT EP.Event_Participant_ID FROM Event_Participants EP
				WHERE EP.Event_ID = E.Event_ID AND EP.Participant_ID = C.Participant_Record AND EP.Group_Participant_ID IS NULL)
			-- Exclude if they are a Volunteer Schedule Participant --
			AND NOT EXISTS(SELECT S.Schedule_ID FROM Schedules S
				WHERE S.Event_ID=E.Event_ID
				AND S.Group_ID=G.Group_ID)
		ORDER BY
			E.Event_Start_Date
			,C.Household_Position_ID
			,C.Nickname;

		-- Insert Volunteer Schedules --
		INSERT INTO #EventsTemp
		SELECT
			E.Event_ID
			,E.Event_Title
			,DATETIMEFROMPARTS(YEAR(E.Event_Start_Date),MONTH(E.Event_Start_Date),DAY(E.Event_Start_Date),
				DATEPART(HOUR,SR.Start_Time),DATEPART(MINUTE,SR.Start_Time),0,0) AS Event_Start_Date
			,DATETIMEFROMPARTS(YEAR(E.Event_End_Date),MONTH(E.Event_End_Date),DAY(E.Event_End_Date),
				DATEPART(HOUR,SR.End_Time),DATEPART(MINUTE,SR.End_Time),0,0) AS Event_End_Date
			,DATEDIFF(day,GetDate(),E.Event_Start_Date) AS DayNumber
			,ISNULL(C.Nickname,C.First_Name) AS [Participant]
			,GR.Role_Title
			,'volunteer-event'
		FROM Events E
			JOIN Schedules S ON S.Event_ID = E.Event_ID
			JOIN Schedule_Roles SR ON SR.Schedule_ID = S.Schedule_ID
			JOIN Scheduled_Participants SP ON SP.Schedule_Role_ID = SR.Schedule_Role_ID
			JOIN Group_Roles GR ON GR.Group_Role_ID = SR.Group_Role_ID
			JOIN Contacts C ON C.Participant_Record=SP.Participant_ID
			JOIN Households H ON H.Household_ID=C.Household_ID
		WHERE
			C.Household_ID = @HouseholdID
			AND E.Event_End_Date BETWEEN GetDate() AND GetDate()+@DaysAhead
			AND E.Cancelled=0
			AND S.Schedule_Status_ID=2
		ORDER BY
			E.Event_Start_Date
			,SR.Start_Time
			,C.Household_Position_ID
			,C.Nickname;

		-- Return DataSet1 - Upcoming Dates within @DaysAhead for Headers --
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

		-- Return DataSet2 - Distinct Upcoming Events --
		SELECT 
			Event_ID
			,Event_Title
			-- Convert Event_Start_Date to UTC. Liquid will convert to user's local time. --
			,DATEADD(MINUTE, -@CurrentOffset, Event_Start_Date) AS [Event_Start_Date]
			,DayNumber
			,STRING_AGG(Participant, ', ') AS [Participants]
			,Event_Type
		FROM (
			SELECT DISTINCT
				Event_ID
				,ISNULL(Role_Title, Event_Title) AS [Event_Title]
				,Event_Start_Date
				,DayNumber
				,Participant
				,Event_Type
			FROM #EventsTemp
		) AS DistinctParticipants
		GROUP BY 
			Event_ID
			,Event_Title
			,Event_Start_Date
			,DayNumber
			,Event_Type
		ORDER BY
			DayNumber
			,Event_Start_Date;

		-- Return DataSet 3 - Featured Events --
		SELECT
		DISTINCT
			E.Event_Title
			,DATEDIFF(day, GetDate(), E.Event_Start_Date) AS DayNumber
			,'featured-event' AS [Event_Type]
		FROM Events E
		WHERE
			(E.Event_Type_ID=@EventTypeId
			OR (@FeaturedEvents=1 AND E.Featured_On_Calendar=1))
			AND E.Event_End_Date BETWEEN GetDate() AND GetDate()+@DaysAhead
			AND (E.Congregation_ID = @HouseholdCongregationID OR E.Congregation_ID = @GlobalCongregationID)
			AND E.Cancelled = 0
			AND E.Visibility_Level_ID = 4
		GROUP BY 
			E.Event_Title
			,E.Event_Start_Date
		ORDER BY DayNumber;

		DROP TABLE #EventsTemp;

	-- END IF SECTION --
	END

END


-- ========================================================================================
-- SP MetaData Install
-- ========================================================================================
DECLARE @spName nvarchar(128) = 'api_custom_MyWeekWidget'
DECLARE @spDescription nvarchar(500) = "Custom Widget SP for returning a user's upcoming week's events"

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