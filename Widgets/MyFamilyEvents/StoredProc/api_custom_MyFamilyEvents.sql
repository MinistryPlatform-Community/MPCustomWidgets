SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[api_custom_MyFamilyEvents]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[api_custom_MyFamilyEvents] AS' 
END
GO



-- =============================================
-- api_custom_MyFamilyEvents
-- =============================================
-- Description:		This stored procedure returns mission trips for the user and family if HOH
-- Last Modified:	2/19/2024
-- Chris Kehayias
-- Updates:
-- 2/19/2024		- Initial Commit
-- =============================================
ALTER PROCEDURE [dbo].[api_custom_MyFamilyEvents] 
	@DomainID int,
	@Username nvarchar(75)
AS
BEGIN

DECLARE @participantID INT = (SELECT C.Participant_Record FROM Contacts C INNER JOIN dp_Users U ON U.User_ID = C.User_Account WHERE U.User_Name=@Username)
DECLARE @householdPositionID INT = (SELECT C.Household_Position_ID FROM Contacts C WHERE C.Participant_Record = @participantID)
DECLARE @householdID INT = (SELECT C.Household_ID FROM Contacts C WHERE C.Participant_Record = @participantID)

--DS 0 ==> My Events
SELECT E.Event_ID
	,E.Event_Title
	,E.Event_Start_Date
FROM Event_Participants EP
INNER JOIN Events E ON E.Event_ID = EP.Event_ID
WHERE EP.Participant_ID = @participantID
AND E.Event_Start_Date > GETDATE()

--DS 1 ==> My Family Events
SELECT E.Event_ID
	,E.Event_Title
	,E.Event_Start_Date
FROM Event_Participants EP
INNER JOIN Events E ON E.Event_ID = EP.Event_ID
WHERE EP.Participant_ID IN (SELECT C.Participant_Record FROM Contacts C WHERE C.Household_ID = @householdID AND C.Participant_Record <> @participantID)
AND E.Event_Start_Date > GETDATE()

END





-- ========================================================================================
-- SP MetaData Install
-- ========================================================================================
DECLARE @spName nvarchar(128) = 'api_custom_MyFamilyEvents'
DECLARE @spDescription nvarchar(500) = 'Custom Widget SP for returning My Family Event Data'

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