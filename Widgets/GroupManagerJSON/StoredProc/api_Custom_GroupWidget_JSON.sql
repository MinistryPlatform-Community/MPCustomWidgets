-- =============================================
-- api_custom_GroupManagerWidget_JSON
-- =============================================
-- Description:		This stored procedure returns a JSON object with group details
-- Last Modified:	6/18/2025
-- Chris Kehayias
-- Updates:

-- =============================================
DROP PROCEDURE IF EXISTS [dbo].[api_custom_GroupManagerWidget_JSON]
GO
/****** Object:  StoredProcedure [dbo].[api_custom_GroupManagerWidget_JSON]    Script Date: 6/18/2025 1:45:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[api_custom_GroupManagerWidget_JSON]
    @DomainID INT,
    @Username NVARCHAR(75) = NULL,
    @GroupID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @contactId INT = (
        SELECT Contact_ID FROM dp_Users WHERE User_Name = @Username
    );

    DECLARE @participantId INT = (
        SELECT Participant_Record FROM Contacts WHERE Contact_ID = @contactId
    );

    -- Validate group access
    IF NOT EXISTS (
        SELECT 1
        FROM Groups G
        WHERE G.Group_ID = @GroupID
          AND (
              G.Primary_Contact = @contactId
              OR @participantId IN (
                  SELECT GP.Participant_ID
                  FROM Group_Participants GP
                  INNER JOIN Group_Roles GR ON GR.Group_Role_ID = GP.Group_Role_ID
                  WHERE GP.Group_ID = @GroupID
                    AND GR.Group_Role_Type_ID = 1
              )
          )
    )
    BEGIN
        SELECT '{"error": "Access denied or group not found."}' AS JsonResult;
        RETURN;
    END;

    DECLARE @LeadersJson NVARCHAR(MAX);
    DECLARE @MembersJson NVARCHAR(MAX);
    DECLARE @GroupJson NVARCHAR(MAX);
    DECLARE @FinalJson NVARCHAR(MAX);

    -- Leaders JSON
    SELECT @LeadersJson = (
        SELECT 
            GP.Participant_ID,
            C.First_Name,
            C.Nickname,
            C.Last_Name,
            C.Email_Address,
            C.Mobile_Phone
        FROM Group_Participants GP
        INNER JOIN Group_Roles GR ON GR.Group_Role_ID = GP.Group_Role_ID
        INNER JOIN Contacts C ON C.Participant_Record = GP.Participant_ID
        WHERE GP.Group_ID = @GroupID
          AND GR.Group_Role_Type_ID = 1
        FOR JSON PATH
    );

    -- Members JSON
    SELECT @MembersJson = (
        SELECT 
            GP.Participant_ID,
            C.First_Name,
            C.Nickname,
            C.Last_Name,
            C.Email_Address,
            C.Mobile_Phone
        FROM Group_Participants GP
        INNER JOIN Group_Roles GR ON GR.Group_Role_ID = GP.Group_Role_ID
        INNER JOIN Contacts C ON C.Participant_Record = GP.Participant_ID
        WHERE GP.Group_ID = @GroupID
          AND GR.Group_Role_Type_ID <> 1
        FOR JSON PATH
    );

    -- Group JSON (excluding leaders/members)
    SELECT @GroupJson = (
        SELECT *
        FROM Groups G
        WHERE G.Group_ID = @GroupID
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    );

    -- Merge into one JSON
    SET @FinalJson = CONCAT(
        LEFT(@GroupJson, LEN(@GroupJson) - 1), -- Strip final closing brace
        ',"Leaders":', ISNULL(@LeadersJson, '[]'),
        ',"Members":', ISNULL(@MembersJson, '[]'),
        '}'
    );

    SELECT @FinalJson AS JsonResult;
END
GO



-- ========================================================================================
-- SP MetaData Install
-- ========================================================================================
DECLARE @spName nvarchar(128) = 'api_custom_GroupManagerWidget_JSON'
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
