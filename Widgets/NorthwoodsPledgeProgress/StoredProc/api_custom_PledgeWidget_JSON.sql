/****** Object:  StoredProcedure [dbo].[api_custom_PledgeWidget_JSON]    Script Date: 7/10/2025 12:43:15 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[api_custom_PledgeWidget_JSON]
GO
/****** Object:  StoredProcedure [dbo].[api_custom_PledgeWidget_JSON]    Script Date: 7/10/2025 12:43:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- api_custom_PledgeWidget_JSON
-- =============================================
-- Description: Returns Contacts and nested Sacraments for a household if user is Head of Household
-- Last Modified: 10/10/2025
-- Chris Kehayias
-- =============================================
CREATE PROCEDURE [dbo].[api_custom_PledgeWidget_JSON]
    @DomainID INT,
    @Username NVARCHAR(75) = null,
	@PledgeID INT
AS
BEGIN
    SET NOCOUNT ON;

	SELECT Campaign_Name,
		Campaign_Goal,
		Committed = (SELECT SUM(Total_Pledge) FROM Pledges WHERE Pledge_Campaign_ID=@PledgeID),
		Given = ISNULL((SELECT SUM(DD.Amount) FROM Donation_Distributions DD INNER JOIN Donations D ON D.Donation_ID=DD.Donation_ID WHERE DD.Pledge_ID=@PledgeID AND D.Batch_ID IS NOT NULL), 0)
	FROM Pledge_Campaigns
	WHERE Pledge_Campaign_ID = @PledgeID
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER


END
GO


-- =============================================
-- SP MetaData Install
-- =============================================
DECLARE @spName NVARCHAR(128) = 'api_custom_PledgeWidget_JSON'
DECLARE @spDescription NVARCHAR(500) = 'Returns Pledge Details to Drive a Pledge Thermometer'

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
