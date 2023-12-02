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
	@MeetingDayID int = null,
	@CongregationID int = null,
	@Keyword nvarchar(50) = NULL,
	@ShowFullAddress bit = 0,
	@ShowFutureGroups bit = 1
AS
BEGIN

	DECLARE @DomainTimeZone dp_TimeZone
	SELECT @DomainTimeZone = Time_Zone FROM dp_Domains WHERE Domain_ID = @DomainID

	DECLARE @DomainTime datetime
	SELECT @DomainTime = dbo.dp_ToLocalTime(GETUTCDATE(), @DomainTimeZone)

	DECLARE @GlobalCongregationID int
	SELECT TOP 1 @GlobalCongregationID = [Value] FROM dp_Configuration_Settings WHERE Application_Code = 'Common' AND [Key_Name] = 'GlobalCongregationId'

--Create Temp Table
SELECT G.Group_Name
,G.Description
,G.Congregation_ID
,G.Start_Date
		,CASE 
			WHEN G.Start_Date > GETDATE() THEN 1
			ELSE NULL
		END AS Future_Start
,G.End_Date
,F.Unique_Name AS ImageGUID
,MD.Meeting_Duration
,MD.Meeting_Duration_ID
,MF.Meeting_Frequency
		,CASE 
			WHEN G.Meeting_Time IS NOT NULL THEN dbo.dp_Convert_DateTime(CAST(G.Meeting_Time AS datetime), @DomainTimeZone, CN.Time_Zone)
			ELSE NULL
		END AS Meeting_Time
,MTD.Meeting_Day
,G.Meeting_Day_ID
,GF.Group_Focus
,G.Group_Focus_ID
,LS.Life_Stage
,G.Life_Stage_ID
,G.Meets_Online
,OA_CurrentParticipants.CurrentParticipantsCount
,G.Target_Size
,OA_GroupInquiries.GroupInquiriesCount
,G.Ministry_ID
,Ministry_ID_Table.Ministry_Name
-- Address Info
-- Taken from MP Widgets Group SP
		,CASE WHEN Offsite_Meeting_Address IS NULL THEN NULL ELSE 1 END AS Offsite
		,CASE WHEN Offsite_Meeting_Address IS NULL 
			THEN 
				CASE @ShowFullAddress WHEN 0 THEN '' ELSE
					Congregation_ID_Table_Location_ID_Table_Address_ID_Table.Address_Line_1 + ' ' +
						 ISNULL(Congregation_ID_Table_Location_ID_Table_Address_ID_Table.Address_Line_2 + ' ', '')
				END +
				ISNULL(Congregation_ID_Table_Location_ID_Table_Address_ID_Table.City + ', ', '') +
				ISNULL(Congregation_ID_Table_Location_ID_Table_Address_ID_Table.[State/Region] + ' ', '') +
				ISNULL(Congregation_ID_Table_Location_ID_Table_Address_ID_Table.Postal_Code, '')
			ELSE 
				CASE @ShowFullAddress WHEN 0 THEN '' ELSE
					Offsite_Meeting_Address_Table.Address_Line_1 + ' ' +
						 ISNULL(Offsite_Meeting_Address_Table.Address_Line_2 + ' ', '') 
				END +
				ISNULL(Offsite_Meeting_Address_Table.City + ', ', '') +
				ISNULL(Offsite_Meeting_Address_Table.[State/Region] + ' ', '') +
				ISNULL(Offsite_Meeting_Address_Table.Postal_Code , '')			
			END AS [Address],
		CASE WHEN Offsite_Meeting_Address IS NOT NULL THEN Offsite_Meeting_Address_Table.City + ', ' + Offsite_Meeting_Address_Table.[State/Region] ELSE CN.Congregation_Name END AS [Location]
		
-- Attributes
,Tags = (
	SELECT STUFF(
		(SELECT ', ' + A.Attribute_Name
			FROM Group_Attributes GA
			INNER JOIN Attributes A ON A.Attribute_ID = GA.Attribute_ID
			WHERE GA.Group_ID = G.Group_ID
            ORDER BY A.Attribute_Name 
        FOR XML PATH('')), 1, 1, '')
		)

INTO #custom_search_group
FROM Groups G
INNER JOIN Group_Types GT ON GT.Group_Type_ID = G.Group_Type_ID
INNER JOIN Congregations CN ON CN.Congregation_ID = G.Congregation_ID
INNER JOIN Ministries Ministry_ID_Table ON Ministry_ID_Table.Ministry_ID = G.Ministry_ID

OUTER APPLY (
	SELECT COUNT(*) AS CurrentParticipantsCount FROM Group_Participants GP WHERE GP.Group_ID = G.Group_ID
	AND GP.[Start_Date] <= @DomainTime AND (GP.End_Date >= @DomainTime OR GP.End_Date IS NULL)
) OA_CurrentParticipants

OUTER APPLY (
	SELECT COUNT(*) AS GroupInquiriesCount FROM Group_Inquiries GI WHERE GI.Group_ID = G.Group_ID AND GI.Placed IS NULL
) OA_GroupInquiries
LEFT OUTER JOIN dp_Files F ON F.Table_Name = 'Groups' AND F.Record_ID = G.Group_ID AND F.Default_Image=1
LEFT OUTER JOIN Meeting_Durations MD ON MD.Meeting_Duration_ID = G.Meeting_Duration_ID
LEFT OUTER JOIN Meeting_Frequencies MF ON MF.Meeting_Frequency_ID = G.Meeting_Frequency_ID
LEFT OUTER JOIN Meeting_Days MTD ON MTD.Meeting_Day_ID = G.Meeting_Day_ID
LEFT OUTER JOIN Group_Focuses GF ON GF.Group_Focus_ID = G.Group_Focus_ID
LEFT OUTER JOIN Life_Stages LS ON LS.Life_Stage_ID = G.Life_Stage_ID

LEFT OUTER JOIN Addresses Offsite_Meeting_Address_Table ON Offsite_Meeting_Address_Table.Address_ID = G.Offsite_Meeting_Address
LEFT OUTER JOIN Locations Congregation_ID_Table_Location_ID_Table ON Congregation_ID_Table_Location_ID_Table.Location_ID = CN.Location_ID
LEFT OUTER JOIN Addresses Congregation_ID_Table_Location_ID_Table_Address_ID_Table ON Congregation_ID_Table_Location_ID_Table_Address_ID_Table.Address_ID = Congregation_ID_Table_Location_ID_Table.Address_ID

WHERE GT.Show_On_Group_Finder = 1
AND (G.End_Date IS NULL OR G.End_Date > @DomainTime)
AND G.Available_Online = 1
AND (G.[Start_Date] < @DomainTime OR @ShowFutureGroups = 1)
AND G.Group_Is_Full = 0


--DataSet1
SELECT * FROM #custom_search_group
WHERE (@GroupFocusID IS NULL OR @GroupFocusID = Group_Focus_ID)
AND (@MeetingDayID IS NULL OR @MeetingDayID = Meeting_Day_ID)
AND (@CongregationID IS NULL OR @CongregationID = Congregation_ID)
AND (@Keyword IS NULL OR 
	(Group_Name LIKE '%' + @Keyword + '%' 
	OR [Description] LIKE '%' + @Keyword + '%' 
	OR Ministry_Name LIKE '%' + @Keyword + '%'
	OR Meeting_Day LIKE '%' + @Keyword + '%'
	OR Life_Stage LIKE '%' + @Keyword + '%'
	OR Group_Focus LIKE '%' + @Keyword + '%'
	OR Tags LIKE '%' + @Keyword + '%'
	OR Meeting_Duration LIKE '%' + @Keyword + '%'
	)
)
ORDER BY Group_Name

--DataSet2 - Focuses
SELECT Group_Focus_ID
	,Group_Focus
FROM Group_Focuses 
WHERE Group_Focus_ID IN
(
	SELECT Group_Focus_ID
	FROM #custom_search_group
)
ORDER BY Group_Focus

--DataSet3 - Meeting Days
SELECT Meeting_Day_ID
	,Meeting_Day
FROM Meeting_Days 
WHERE Meeting_Day_ID IN
(
	SELECT Meeting_Day_ID
	FROM #custom_search_group
)

--DataSet4 - Congregations
SELECT Congregation_ID
	,Congregation_Name
FROM Congregations
WHERE Available_Online = 1
	AND (End_Date IS NULL OR End_Date > @DomainTime)

-- DataSet5 - Ministries
SELECT Ministry_ID
	,Ministry_Name
FROM Ministries
WHERE Ministry_ID IN 
(
	SELECT Ministry_ID
	FROM #custom_search_group
)

-- DataSet6 - Life Stages
SELECT Life_Stage_ID
	,Life_Stage
FROM Life_Stages
WHERE Life_Stage_ID IN 
(
	SELECT Life_Stage_ID
	FROM #custom_search_group
)

DROP TABLE #custom_search_group
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
