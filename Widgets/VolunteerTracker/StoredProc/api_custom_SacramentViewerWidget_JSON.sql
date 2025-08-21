/****** Object:  StoredProcedure [dbo].[api_custom_VolunteerTrackerWidget]    Script Date: 7/10/2025 12:43:15 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[api_custom_VolunteerTrackerWidget]
GO
/****** Object:  StoredProcedure [dbo].[api_custom_VolunteerTrackerWidget]    Script Date: 7/10/2025 12:43:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- api_custom_VolunteerTrackerWidget
-- =============================================
-- Description: Returns Contacts and nested Sacraments for a household if user is Head of Household
-- Last Modified: 7/10/2025
-- Chris Kehayias
-- =============================================
CREATE PROCEDURE [dbo].[api_custom_VolunteerTrackerWidget]
    @DomainID INT,
    @ResponseID INT,
    @ContactGUID NVARCHAR(50)
AS
BEGIN
    -- CODE GOES HERE
END
GO


-- =============================================
-- SP MetaData Install
-- =============================================
DECLARE @spName NVARCHAR(128) = 'api_custom_VolunteerTrackerWidget'
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
