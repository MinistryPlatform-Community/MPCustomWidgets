/****** Object:  StoredProcedure [dbo].[api_custom_SacramentViewerWidget_JSON]    Script Date: 7/10/2025 12:43:15 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[api_custom_SacramentViewerWidget_JSON]
GO
/****** Object:  StoredProcedure [dbo].[api_custom_SacramentViewerWidget_JSON]    Script Date: 7/10/2025 12:43:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- api_custom_SacramentViewerWidget_JSON
-- =============================================
-- Description: Returns Contacts and nested Sacraments for a household if user is Head of Household
-- Last Modified: 7/10/2025
-- Chris Kehayias
-- =============================================
CREATE PROCEDURE [dbo].[api_custom_SacramentViewerWidget_JSON]
    @DomainID INT,
    @Username NVARCHAR(75)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @contactId INT = (
        SELECT Contact_ID FROM dp_Users WHERE User_Name = @Username
    );

    DECLARE @householdID INT = (
        SELECT Household_ID FROM Contacts WHERE Contact_ID = @contactId
    );

    DECLARE @participantId INT = (
        SELECT Participant_Record FROM Contacts WHERE Contact_ID = @contactId
    );

    DECLARE @houseHoldPositionId INT = (
        SELECT Household_Position_ID FROM Contacts WHERE Contact_ID = @contactId
    );

    IF @houseHoldPositionId = 1
    BEGIN
        SELECT [JsonResult] = (
            SELECT (
                SELECT 
                    C.Nickname,
					C.Last_Name,
					C.Household_Position_ID,
					HP.Household_Position,
					F.Unique_Name,
                    (
                        SELECT 
                            S.Sacrament_ID,
                            ST.Sacrament_Type,
                            COALESCE(S.Place_Name, SP.Place_Name) AS Place,
                            S.Date_Received,
							COALESCE(S.Performed_By_Name, PC.Display_Name) AS Performed_By,
							COALESCE(S.Spouse_Name, CONCAT(SC.Nickname, ' ', SC.Last_Name)) AS Spouse_Name
                        FROM Sacraments S
                        INNER JOIN Sacrament_Types ST ON ST.Sacrament_Type_ID = S.Sacrament_Type_ID
                        LEFT OUTER JOIN Sacrament_Places SP ON SP.Sacrament_Place_ID = S.Place_ID
						LEFT OUTER JOIN Contacts PC ON PC.Participant_Record = S.Performed_By_ID
						LEFT OUTER JOIN Contacts SC ON SC.Participant_Record = S.Spouse_ID
                        WHERE S.Participant_ID = C.Participant_Record
						AND ISNULL(S.Annulment, 0) = 0
                        FOR JSON PATH
                    ) AS Sacraments
                FROM Contacts C
				LEFT OUTER JOIN Household_Positions HP ON HP.Household_Position_ID = C.Household_Position_ID
				LEFT OUTER JOIN dp_Files F ON F.Table_Name='Contacts' AND F.Record_ID=C.Contact_ID AND F.Default_Image=1
                WHERE C.Household_ID = @householdID
                FOR JSON PATH
            ) AS contacts,
			( select CONCAT('https://', External_Server_Name, '/ministryplatformapi/files/') AS fileUri from dp_domains ) as domain
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        )
    END
END
GO


-- =============================================
-- SP MetaData Install
-- =============================================
DECLARE @spName NVARCHAR(128) = 'api_custom_SacramentViewerWidget_JSON'
DECLARE @spDescription NVARCHAR(500) = 'Returns Contacts with nested Sacraments if user is Head of Household'

IF NOT EXISTS (
    SELECT API_Procedure_ID FROM dp_API_Procedures WHERE Procedure_Name = @spName
)
BEGIN
    INSERT INTO dp_API_Procedures (Procedure_Name, Description)
    VALUES (@spName, @spDescription)
END

-- Grant to Administrators Role
DECLARE @AdminRoleID INT = (
    SELECT Role_ID FROM dp_Roles WHERE Role_Name = 'Administrators'
)

IF NOT EXISTS (
    SELECT * 
    FROM dp_Role_API_Procedures RP
    INNER JOIN dp_API_Procedures AP ON AP.API_Procedure_ID = RP.API_Procedure_ID
    WHERE AP.Procedure_Name = @spName AND RP.Role_ID = @AdminRoleID
)
BEGIN
    INSERT INTO dp_Role_API_Procedures (Domain_ID, API_Procedure_ID, Role_ID)
    VALUES (
        1,
        (SELECT API_Procedure_ID FROM dp_API_Procedures WHERE Procedure_Name = @spName),
        @AdminRoleID
    )
END
GO
