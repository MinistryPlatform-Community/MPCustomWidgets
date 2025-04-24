SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[api_custom_PlatformWidgetSermonPlayer]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[api_custom_PlatformWidgetSermonPlayer] AS' 
END
GO


-- =============================================
-- api_custom_PlatformWidgetSermonPlayer
-- =============================================
-- Description:		This stored procedure returns user Data for Platform Sermon Widget
-- Last Modified:	4/16/2025
-- Chris Kehayias
-- Updates:
-- 4/16/2025		- Initial Commit
-- =============================================
ALTER PROCEDURE [dbo].[api_custom_PlatformWidgetSermonPlayer] 
	@DomainID int,
	@Username nvarchar(75),
	@SermonID int
AS
BEGIN

DECLARE @participantID INT = (SELECT C.Participant_Record FROM Contacts C INNER JOIN dp_Users U ON U.User_ID = C.User_Account WHERE U.User_Name=@Username)
DECLARE @householdPositionID INT = (SELECT C.Household_Position_ID FROM Contacts C WHERE C.Participant_Record = @participantID)
DECLARE @householdID INT = (SELECT C.Household_ID FROM Contacts C WHERE C.Participant_Record = @participantID)

SELECT * FROM Pocket_Platform_Sermons
WHERE Sermon_ID = @SermonID

SELECT * FROM Pocket_Platform_Sermon_Links PPS
WHERE PPS.Sermon_ID = @SermonID
AND PPS.Link_Type_ID IN (1,2)



END





-- ========================================================================================
-- SP MetaData Install
-- ========================================================================================
DECLARE @spName nvarchar(128) = 'api_custom_PlatformWidgetSermonPlayer'
DECLARE @spDescription nvarchar(500) = 'Custom Widget SP for Platform Sermon Widget'

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
