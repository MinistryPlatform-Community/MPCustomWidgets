SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[api_Custom_BrowserCommunication]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[api_Custom_BrowserCommunication] AS' 
END
GO



-- =============================================
-- api_Custom_BrowserCommunication
-- =============================================
-- Description:		This stored procedure returns a Communication Record Based on GUID
-- Last Modified:	11/15/2023
-- Chris Kehayias
-- Updates:
-- =============================================
ALTER PROCEDURE  [dbo].[api_Custom_BrowserCommunication]

	@DomainID INT
	,@UserName nvarchar(75) = null
	,@CommunicationGUID uniqueidentifier

AS
BEGIN

	-- DataSet1 Communication
	SELECT 
		C.Communication_ID
		,C.Subject
		,C.Start_Date
		,C.Communication_GUID
		,C.Body
	FROM dp_Communications C
	WHERE C.Communication_GUID = @CommunicationGUID

END
GO



-- ========================================================================================
-- SP MetaData Install
-- ========================================================================================
DECLARE @spName nvarchar(128) = 'api_Custom_BrowserCommunication'
DECLARE @spDescription nvarchar(500) = 'Custom Widget SP for returning Communication Records by GUID'

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