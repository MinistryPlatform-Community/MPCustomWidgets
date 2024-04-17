SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[api_custom_CampaignProgress]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[api_custom_CampaignProgress] AS' 
END
GO



-- =============================================
-- api_custom_CampaignProgress
-- =============================================
-- Description:		Custom Widget SP for returning Campaign Progress by Parish
-- Last Modified:	4/11/2024
-- Chris Kehayias
-- Updates:
--		4/11 - Initial
-- =============================================
CREATE PROCEDURE [dbo].[api_custom_CampaignProgress] 
	@DomainID int,
	@PledgeCampaignID int
AS
BEGIN


SELECT CG.*,
	A.City,
	Participation = (
		SELECT CASE WHEN (
			SELECT COUNT(DISTINCT(C.Household_ID)) FROM Contacts C JOIN Households H ON H.Household_ID = C.Household_ID WHERE H.Congregation_ID = CG.[Organization_ID] AND C.Contact_Status_ID = 1) = 0 THEN 0 ELSE
		CAST((SELECT COUNT(DISTINCT(C.Household_ID)) FROM Pledges P JOIN Donors D ON D.Donor_ID = P.Donor_ID JOIN Contacts C ON C.Donor_Record = D.Donor_ID WHERE P.Pledge_Campaign_ID = CG.Pledge_Campaign_ID AND P.Parish_Credited_ID = CG.Organization_ID) as float)/CAST((SELECT COUNT(DISTINCT(C.Household_ID)) FROM Contacts C JOIN Households H ON H.Household_ID = C.Household_ID WHERE H.Congregation_ID = CG.[Organization_ID] AND C.Contact_Status_ID = 1) as float)*100 END)
FROM vw_mp_Campaign_Goals CG
INNER JOIN Congregations CN ON CN.Congregation_ID = CG.Organization_ID
LEFT OUTER JOIN Locations L ON L.Location_ID = CN.Location_ID
LEFT OUTER JOIN Addresses A ON A.Address_ID = L.Address_ID
WHERE CG.Pledge_Campaign_ID = @PledgeCampaignID

END
GO










-- ========================================================================================
-- SP MetaData Install
-- ========================================================================================
DECLARE @spName nvarchar(128) = 'api_custom_CampaignProgress'
DECLARE @spDescription nvarchar(500) = 'Custom Widget SP for returning Campaign Progress Data'

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