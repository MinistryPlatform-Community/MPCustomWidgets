SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[api_custom_StaffWidget]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[api_custom_StaffWidget] AS' 
END
GO



-- =============================================
-- api_custom_StaffWidget
-- =============================================
-- Description:		This stored procedure returns Staff Members
-- Last Modified:	4/17/2024
-- Chris Kehayias
-- Updates:
-- 4/17/2024		- Initial Commit
-- =============================================
ALTER PROCEDURE [dbo].[api_custom_StaffWidget] 
	@DomainID int,
	@UserName nvarchar(75) = null
AS
BEGIN


	SELECT 
		C.Nickname
		,C.First_Name
		,C.Last_Name
		,C.Email_Address
		,C.Mobile_Phone
		,C.Contact_GUID
		,S.Facebook_URL
		,S.Title
		,Image_GUID = COALESCE(SF.Unique_Name, CF.Unique_Name)
		,File_URL = CONCAT('https://', D.External_Server_Name, '/ministryplatformapi/files/')
	FROM Staff S
	INNER JOIN Contacts C ON C.Contact_ID = S.Contact_ID
	INNER JOIN dp_Domains D ON D.Domain_ID = @DomainID
	LEFT OUTER JOIN dp_Files CF ON CF.Table_Name='Contacts' AND CF.Record_ID=C.Contact_ID AND CF.Default_Image = 1
	LEFT OUTER JOIN dp_Files SF ON SF.Table_Name='Staff' AND SF.Record_ID=S.Staff_ID AND SF.Default_Image = 1
	WHERE S.Start_Date < GETDATE()
	AND (S.End_Date IS NULL OR S.End_Date > GETDATE())
	AND S.Show_Online = 1
	ORDER BY S.Online_Order


END









-- ========================================================================================
-- SP MetaData Install
-- ========================================================================================
DECLARE @spName nvarchar(128) = 'api_custom_StaffWidget'
DECLARE @spDescription nvarchar(500) = 'Custom Widget SP for returning Staff Widget Data'

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