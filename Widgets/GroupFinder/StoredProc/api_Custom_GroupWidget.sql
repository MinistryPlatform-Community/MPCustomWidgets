SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[api_custom_GroupWidget]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[api_custom_GroupWidget] AS' 
END
GO


-- =============================================
-- api_CustomWidget
-- =============================================
-- Description:		This stored procedure returns a count of small groups
-- Last Modified:	11/13/2023
-- Chris Kehayias
-- Updates:
-- =============================================
ALTER PROCEDURE [dbo].[api_custom_GroupWidget] 
	@DomainID int,
	@UserName nvarchar(75) = null
AS
BEGIN

SELECT G.Group_Name
,G.Description
,G.Start_Date
,G.End_Date
,F.Unique_Name AS ImageGUID
FROM Groups G
LEFT OUTER JOIN dp_Files F ON F.Table_Name = 'Groups' AND F.Record_ID = G.Group_ID AND F.Default_Image=1
WHERE G.Group_Type_ID = 1
AND (G.End_Date IS NULL OR G.End_Date > GETDATE())
AND Available_Online = 1



SELECT COUNT(*) AS Group_Count
FROM Groups G
WHERE G.Group_Type_ID = 1
AND (G.End_Date IS NULL OR G.End_Date > GETDATE())
AND Available_Online = 1



END
GO


-- ========================================================================================
-- SP MetaData Install
-- ========================================================================================
DECLARE @spName nvarchar(128) = 'api_custom_GroupWidget'
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