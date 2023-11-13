SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[api_Custom_Publication_Messages]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[api_Custom_Publication_Messages] AS' 
END
GO




-- =============================================
-- api_Custom_Publication_Messages
-- =============================================
-- Description:		This stored procedure returns Publications and Messages
-- Last Modified:	11/13/2023
-- Chris Kehayias
-- Updates:
-- =============================================
ALTER PROCEDURE  [dbo].[api_Custom_Publication_Messages]

	@DomainID INT
	,@UserName nvarchar(75) = null
	,@PublicationID int
	,@MessageID int = null

AS
BEGIN

	-- DataSet1 Publication Details
	SELECT * 
	FROM dp_Publications
	WHERE Publication_ID = @PublicationID

	--DataSet2 Publication Messages
	SELECT 
		C.Communication_ID
		,C.Subject
		,C.Start_Date
	FROM dp_Communication_Publications CP
	INNER JOIN dp_Publications P ON P.Publication_ID = CP.Publication_ID
	INNER JOIN dp_Communications C ON C.Communication_ID = CP.Communication_ID
	WHERE P.Publication_ID = @PublicationID

	--DataSet3 Message
	SELECT 
		C.Communication_ID
		,C.Body
		,C.Subject
		,C.Start_Date
	FROM dp_Communication_Publications CP
	INNER JOIN dp_Publications P ON P.Publication_ID = CP.Publication_ID
	INNER JOIN dp_Communications C ON C.Communication_ID = CP.Communication_ID
	WHERE P.Publication_ID = @PublicationID
	AND CP.Communication_ID = @MessageID


END
GO



-- ========================================================================================
-- SP MetaData Install
-- ========================================================================================
DECLARE @spName nvarchar(128) = 'api_Custom_Publication_Messages'
DECLARE @spDescription nvarchar(500) = 'Custom Widget SP for Publications and Messages'

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