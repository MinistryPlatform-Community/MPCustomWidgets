SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[api_custom_MilestoneGamification]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[api_custom_MilestoneGamification] AS' 
END
GO



-- =============================================
-- api_Custom_MilestoneGamification
-- =============================================
-- Description:		This stored procedure returns a milestones accomplished by the user.
-- Last Modified:	11/16/2023
-- Chris Kehayias
-- Updates:
-- 12/1/2023		- Added Journey Support 
-- =============================================
ALTER PROCEDURE [dbo].[api_custom_MilestoneGamification] 
	@DomainID int,
	@Username nvarchar(75),
	@JourneyID INT = 2
AS
BEGIN


	DECLARE @participantID INT = (SELECT C.Participant_Record FROM Contacts C INNER JOIN dp_Users U ON U.User_ID = C.User_Account WHERE U.User_Name=@Username)

	--DataSet1
	SELECT 
		M.Milestone_ID
		,M.Milestone_Title
		,M.Description
		,CASE 
			WHEN EXISTS (SELECT 1 FROM Participant_Milestones WHERE Milestone_ID = M.Milestone_ID AND Participant_ID = @participantID) THEN 1
			ELSE NULL
		END AS MilestoneAchieved
	FROM Milestones M
	WHERE M.Journey_ID = @JourneyID
	ORDER BY M.Sort_Order

END



-- ========================================================================================
-- SP MetaData Install
-- ========================================================================================
DECLARE @spName nvarchar(128) = 'api_custom_MilestoneGamification'
DECLARE @spDescription nvarchar(500) = 'Custom Widget SP for returning Groups Data'

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