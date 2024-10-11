/****** Object:  StoredProcedure [dbo].[api_custom_Dashboard]    Script Date: 10/11/2024 12:12:48 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[api_custom_Dashboard]
GO
/****** Object:  StoredProcedure [dbo].[api_custom_Dashboard]    Script Date: 10/11/2024 12:12:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- api_custom_Dashboard
-- =============================================
-- Description:		This stored procedure returns dashboard data
-- Last Modified:	10/11/2024
-- Chris Kehayias
-- Updates:
--		10/11/2024 - Initial Creation
-- =============================================
CREATE PROCEDURE [dbo].[api_custom_Dashboard] 
	@DomainID int,
	@Username nvarchar(75) = null
AS
BEGIN

	DECLARE @DomainTimeZone dp_TimeZone
	SELECT @DomainTimeZone = Time_Zone FROM dp_Domains WHERE Domain_ID = @DomainID

	DECLARE @DomainTime datetime
	SELECT @DomainTime = dbo.dp_ToLocalTime(GETUTCDATE(), @DomainTimeZone)

	DECLARE @GlobalCongregationID int
	SELECT TOP 1 @GlobalCongregationID = [Value] FROM dp_Configuration_Settings WHERE Application_Code = 'Common' AND [Key_Name] = 'GlobalCongregationId'

	-- DS 0 - Events
	SELECT 
		YEAR(Event_Start_Date) AS EventYear,
		MONTH(Event_Start_Date) AS EventMonth,
		DATENAME(MONTH, Event_Start_Date) AS MonthName,
		COUNT(*) AS EventCount
	FROM Events
	WHERE Event_Start_Date >= DATEADD(MONTH, -12, GETDATE())
	AND Event_Start_Date < GETDATE()
	GROUP BY YEAR(Event_Start_Date), MONTH(Event_Start_Date), DATENAME(MONTH, Event_Start_Date)
	ORDER BY EventYear, EventMonth;

	-- DS 0 - Event Types
	SELECT ET.Event_Type, COUNT(*) AS TypeCount 
	FROM Events E
	INNER JOIN Event_Types ET ON ET.Event_Type_ID = E.Event_Type_ID
	WHERE Event_Start_Date >= DATEADD(MONTH, -12, GETDATE())
	AND Event_Start_Date < GETDATE()
	GROUP BY ET.Event_Type

END
GO



-- ========================================================================================
-- SP MetaData Install
-- ========================================================================================
DECLARE @spName nvarchar(128) = 'api_custom_Dashboard'
DECLARE @spDescription nvarchar(500) = 'Custom Widget SP for returning Dashboard Data'

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
