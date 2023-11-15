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
--		11/15 - Added GroupFocusID / MeetingDataID Parameters
-- =============================================
ALTER PROCEDURE [dbo].[api_custom_GroupWidget] 
	@DomainID int,
	@Username nvarchar(75) = null,
	@GroupFocusID int = null,
	@MeetingDayID int = null
AS
BEGIN

--DataSet1
SELECT G.Group_Name
,G.Description
,G.Start_Date
,G.End_Date
,F.Unique_Name AS ImageGUID
,MD.Meeting_Duration
,MF.Meeting_Frequency
,MTD.Meeting_Day
,GF.Group_Focus
,LS.Life_Stage
FROM Groups G
LEFT OUTER JOIN dp_Files F ON F.Table_Name = 'Groups' AND F.Record_ID = G.Group_ID AND F.Default_Image=1
LEFT OUTER JOIN Meeting_Durations MD ON MD.Meeting_Duration_ID = G.Meeting_Duration_ID
LEFT OUTER JOIN Meeting_Frequencies MF ON MF.Meeting_Frequency_ID = G.Meeting_Frequency_ID
LEFT OUTER JOIN Meeting_Days MTD ON MTD.Meeting_Day_ID = G.Meeting_Day_ID
LEFT OUTER JOIN Group_Focuses GF ON GF.Group_Focus_ID = G.Group_Focus_ID
LEFT OUTER JOIN Life_Stages LS ON LS.Life_Stage_ID = G.Life_Stage_ID
WHERE G.Group_Type_ID = 1
AND (G.End_Date IS NULL OR G.End_Date > GETDATE())
AND Available_Online = 1
AND (@GroupFocusID IS NULL OR @GroupFocusID = G.Group_Focus_ID)
AND (@MeetingDayID IS NULL OR @MeetingDayID = G.Meeting_Day_ID)

--DataSet2
SELECT Group_Focus_ID
	,Group_Focus
FROM Group_Focuses 
WHERE Group_Focus_ID IN
(
	SELECT G.Group_Focus_ID
	FROM Groups G
	WHERE G.Group_Type_ID = 1
	AND (G.End_Date IS NULL OR G.End_Date > GETDATE())
	AND Available_Online = 1
)

--DataSet3
SELECT Meeting_Day_ID
	,Meeting_Day
FROM Meeting_Days 
WHERE Meeting_Day_ID IN
(
	SELECT G.Meeting_Day_ID
	FROM Groups G
	WHERE G.Group_Type_ID = 1
	AND (G.End_Date IS NULL OR G.End_Date > GETDATE())
	AND Available_Online = 1
)


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