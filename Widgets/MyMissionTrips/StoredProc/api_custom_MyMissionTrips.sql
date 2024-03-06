SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[api_custom_MyMissionTrips]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[api_custom_MyMissionTrips] AS' 
END
GO



-- =============================================
-- api_custom_MyMissionTrips
-- =============================================
-- Description:		This stored procedure returns mission trips for the user and family if HOH
-- Last Modified:	2/19/2024
-- Chris Kehayias
-- Updates:
-- 2/19/2024		- Initial Commit
-- 2/22/2024		- Added HoH Support / Donor Details
-- 2/23/2024		- Added MyTrip Detection
-- 3/5/2024			- Added Mission Trip Leader
-- =============================================
ALTER PROCEDURE [dbo].[api_custom_MyMissionTrips] 
	@DomainID int,
	@Username nvarchar(75),
	@PledgeID INT = null	
AS
BEGIN


	DECLARE @participantID INT = (SELECT C.Participant_Record FROM Contacts C INNER JOIN dp_Users U ON U.User_ID = C.User_Account WHERE U.User_Name=@Username)
	DECLARE @donorID INT = (SELECT C.Donor_Record FROM Contacts C INNER JOIN dp_Users U ON U.User_ID = C.User_Account WHERE U.User_Name=@Username)
	DECLARE @householdPositionID INT = (SELECT C.Household_Position_ID FROM Contacts C WHERE C.Donor_Record = @donorID)
	DECLARE @householdID INT = (SELECT C.Household_ID FROM Contacts C WHERE C.Donor_Record = @donorID)

	-- Get List of Pledges to Show the User
	SELECT P.Pledge_ID
	INTO #Pledges
	FROM Pledges P
	INNER JOIN Pledge_Campaigns PC ON PC.Pledge_Campaign_ID = P.Pledge_Campaign_ID
	INNER JOIN Events E ON E.Event_ID = PC.Event_ID
	WHERE PC.Pledge_Campaign_Type_ID = 2
	AND E.Event_End_Date > DATEADD(d, -45, GETDATE())	
	AND P.Pledge_Status_ID <= 2
	AND (
		P.Donor_ID = @donorID OR
		(@householdPositionID = 1 AND P.Donor_ID IN (SELECT Donor_Record FROM Contacts WHERE Household_ID=@householdID))
		)

	-- Get List of Pledge Campaigns the User is a Trip Leader for
	SELECT PC.Pledge_Campaign_ID
	INTO #TripLeaders
	FROM Pledges P
	INNER JOIN Pledge_Campaigns PC ON PC.Pledge_Campaign_ID = P.Pledge_Campaign_ID
	INNER JOIN Events E ON E.Event_ID = PC.Event_ID
	WHERE PC.Pledge_Campaign_Type_ID = 2
	AND E.Event_End_Date > DATEADD(d, -45, GETDATE())	
	AND P.Pledge_Status_ID <= 2
	AND EXISTS (
		SELECT 1 FROM Pledges WHERE Pledge_Campaign_ID = PC.Pledge_Campaign_ID AND Donor_ID = @donorID AND Trip_Leader = 1
		)	

	-- Dataset 1: Pledges
	SELECT E.Event_Title
		,E.Event_Start_Date
		,E.Event_End_Date
		,E.Description
		,C.Nickname
		,C.Last_Name
		,P.Pledge_ID
		,PC.Pledge_Campaign_ID
		,P.Total_Pledge
		,P.Trip_Leader
		,PS.Pledge_Status
		,P.Pledge_ID
		,Total_Donations = (SELECT ISNULL(SUM(DD.Amount),0) FROM Donation_Distributions DD INNER JOIN Donations D ON D.Donation_ID = DD.Donation_ID WHERE DD.Pledge_ID = P.Pledge_ID)
		,Last_Donation = (SELECT MAX(D.Donation_Date) FROM Donation_Distributions DD INNER JOIN Donations D ON D.Donation_ID = DD.Donation_ID WHERE DD.Pledge_ID = P.Pledge_ID)
		,CASE WHEN F.Unique_Name IS NOT NULL THEN CONCAT('https://', DM.External_Server_Name, '/ministryplatformapi/files/', F.Unique_Name) ELSE NULL END AS ImageUrl
		,CASE WHEN P.Donor_ID = @donorID THEN 1 ELSE 0 END AS MyTrip
	FROM Pledges P
	INNER JOIN Donors DN ON DN.Donor_ID = P.Donor_ID
	INNER JOIN Contacts C ON C.Contact_ID = DN.Contact_ID
	INNER JOIN Pledge_Campaigns PC ON PC.Pledge_Campaign_ID = P.Pledge_Campaign_ID
	INNER JOIN Events E ON E.Event_ID = PC.Event_ID
	INNER JOIN Pledge_Statuses PS ON PS.Pledge_Status_ID = P.Pledge_Status_ID
	INNER JOIN dp_Domains DM ON PC.Domain_ID = DM.Domain_ID AND DM.Domain_ID = @DomainID
	LEFT OUTER JOIN dp_Files F ON F.Table_Name = 'Events' AND F.Record_ID = E.Event_ID AND F.Default_Image = 1
	WHERE P.Pledge_ID IN (SELECT Pledge_ID FROM #Pledges)

	-- Dataset 2: Get Pledge Donors
	SELECT 
		DD.Amount
		,DN.Donation_Date
		,C.Nickname
		,C.First_Name
		,C.Last_Name
		,DN.Anonymous
		,DD.Pledge_ID
		,A.Address_Line_1
		,A.Address_Line_2
		,A.City
		,A.Postal_Code
		,A.[State/Region] AS State
	FROM Donation_Distributions DD
	INNER JOIN Donations DN ON DN.Donation_ID = DD.Donation_ID
	INNER JOIN Donors D ON D.Donor_ID = DN.Donor_ID
	INNER JOIN Contacts C ON C.Contact_ID = D.Contact_ID
	LEFT OUTER JOIN Households H ON H.Household_ID = C.Household_ID
	LEFT OUTER JOIN Addresses A ON A.Address_ID = H.Address_ID
	WHERE DD.Pledge_ID IN (SELECT Pledge_ID FROM #Pledges)


	-- Dataset 3: Trip Leader Trips
	SELECT E.Event_Title
		,E.Event_Start_Date
		,E.Event_End_Date
		,E.Description
		,Total_Donations = (
			SELECT ISNULL(SUM(DD.Amount),0) FROM Donation_Distributions DD INNER JOIN Donations D ON D.Donation_ID = DD.Donation_ID WHERE DD.Pledge_ID IN (SELECT Pledge_ID FROM Pledges WHERE Pledge_Campaign_ID = PC.Pledge_Campaign_ID AND Pledge_Status_ID <= 2)
		)
		,Total_Goal = (
			SELECT SUM(Total_Pledge) FROM Pledges
			WHERE Pledge_ID IN  (SELECT Pledge_ID FROM Pledges WHERE Pledge_Campaign_ID = PC.Pledge_Campaign_ID AND Pledge_Status_ID <= 2)
		)
		,CASE WHEN F.Unique_Name IS NOT NULL THEN CONCAT('https://', DM.External_Server_Name, '/ministryplatformapi/files/', F.Unique_Name) ELSE NULL END AS ImageUrl
		,PC.Pledge_Campaign_ID
	FROM Pledge_Campaigns PC	
	INNER JOIN Events E ON E.Event_ID = PC.Event_ID
	INNER JOIN dp_Domains DM ON PC.Domain_ID = DM.Domain_ID AND DM.Domain_ID = @DomainID
	LEFT OUTER JOIN dp_Files F ON F.Table_Name = 'Events' AND F.Record_ID = E.Event_ID AND F.Default_Image = 1
	WHERE PC.Pledge_Campaign_ID IN (SELECT Pledge_Campaign_ID FROM #TripLeaders)


	-- Dataset 4: Trip Leader Participants
	SELECT E.Event_Title
		,E.Event_Start_Date
		,E.Event_End_Date
		,E.Description
		,C.Nickname
		,C.Last_Name
		,P.Pledge_ID
		,PC.Pledge_Campaign_ID
		,P.Total_Pledge
		,P.Trip_Leader
		,PS.Pledge_Status
		,P.Pledge_ID
		,Total_Donations = (SELECT ISNULL(SUM(DD.Amount),0) FROM Donation_Distributions DD INNER JOIN Donations D ON D.Donation_ID = DD.Donation_ID WHERE DD.Pledge_ID = P.Pledge_ID)
		,Last_Donation = (SELECT MAX(D.Donation_Date) FROM Donation_Distributions DD INNER JOIN Donations D ON D.Donation_ID = DD.Donation_ID WHERE DD.Pledge_ID = P.Pledge_ID)
		,CASE WHEN F.Unique_Name IS NOT NULL THEN CONCAT('https://', DM.External_Server_Name, '/ministryplatformapi/files/', F.Unique_Name) ELSE NULL END AS ImageUrl
		,CASE WHEN P.Donor_ID = @donorID THEN 1 ELSE 0 END AS MyTrip
	FROM Pledges P
	INNER JOIN Donors DN ON DN.Donor_ID = P.Donor_ID
	INNER JOIN Contacts C ON C.Contact_ID = DN.Contact_ID
	INNER JOIN Pledge_Campaigns PC ON PC.Pledge_Campaign_ID = P.Pledge_Campaign_ID
	INNER JOIN Events E ON E.Event_ID = PC.Event_ID
	INNER JOIN Pledge_Statuses PS ON PS.Pledge_Status_ID = P.Pledge_Status_ID
	INNER JOIN dp_Domains DM ON PC.Domain_ID = DM.Domain_ID AND DM.Domain_ID = @DomainID
	LEFT OUTER JOIN dp_Files F ON F.Table_Name = 'Events' AND F.Record_ID = E.Event_ID AND F.Default_Image = 1
	WHERE P.Pledge_Campaign_ID IN (SELECT Pledge_Campaign_ID FROM #TripLeaders)
	AND P.Pledge_Status_ID <= 2
	
	-- Clean up Temp Tables
	DROP TABLE #Pledges
	DROP TABLE #TripLeaders
END









-- ========================================================================================
-- SP MetaData Install
-- ========================================================================================
DECLARE @spName nvarchar(128) = 'api_custom_MyMissionTrips'
DECLARE @spDescription nvarchar(500) = 'Custom Widget SP for returning Mission Trip Data'

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