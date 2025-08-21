/*    ==Scripting Parameters==

    Source Server Version : SQL Server 2016 (13.0.7055)
    Source Database Engine Edition : Microsoft SQL Server Enterprise Edition
    Source Database Engine Type : Standalone SQL Server

    Target Server Version : SQL Server 2017
    Target Database Engine Edition : Microsoft SQL Server Standard Edition
    Target Database Engine Type : Standalone SQL Server
*/

USE [MinistryPlatform]
GO
/****** Object:  StoredProcedure [dbo].[api_Common_GenerateSlug]    Script Date: 8/21/2025 3:48:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/************************************************************************************************************************************/
/*	VERSION			AUTHOR			DATE		DESCRIPTION																			*/
/*	1.00			Chris Kehayias	10/6/2022	Initial SP Creation																	*/																																															
/*																																	*/
/*																																	*/
/*																																	*/
/*																																	*/
/************************************************************************************************************************************/


ALTER PROCEDURE [dbo].[api_Common_GenerateSlug]

	@DomainID int,
	@TableName varchar(50),
	@RecordID int = null,
	@SubPage varchar(50) = null

AS
BEGIN

	DECLARE @domainUrl nvarchar(255) = (
		SELECT External_Server_Name 
		FROM dp_Domains
		WHERE Domain_ID=@DomainID)

	DECLARE @pageID int = (
		SELECT TOP 1 Page_ID 
		FROM dp_Pages
		WHERE Table_Name LIKE @TableName
		ORDER BY Filter_Clause)

	DECLARE @subPageID int = null

	IF (@SubPage IS NOT NULL)
	BEGIN

	SET @subPageID = (
		SELECT TOP 1 Sub_Page_ID 
		FROM dp_Sub_Pages
		WHERE Parent_Page_ID = (SELECT TOP 1 Page_ID FROM dp_Pages WHERE Table_Name LIKE @TableName ORDER BY Filter_Clause)
		AND Display_Name LIKE @SubPage
	)
	END

	IF (@RecordID IS NOT NULL AND @subPageID IS NOT NULL)
	BEGIN
		SELECT CONCAT('https://', @domainUrl, '/mp/', @pageID, '/', @RecordID, '/', @subPageID) AS SLUG
	END

	ELSE IF (@RecordID IS NOT NULL)
	BEGIN
		SELECT CONCAT('https://', @domainUrl, '/mp/', @pageID, '/', @RecordID) AS SLUG
	END

	ELSE
	BEGIN
		SELECT CONCAT('https://', @domainUrl, '/mp/', @pageID) AS SLUG
	END
END

