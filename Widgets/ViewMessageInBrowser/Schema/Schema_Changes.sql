

-- =============================================
-- Browser Communication Widget Schema Modifications
-- =============================================
-- Description:		Adds a GUID Column and Auto Populates it for dp_Communications
-- Last Modified:	11/15/2023
-- Chris Kehayias
-- Updates:
-- =============================================
-- =============================================
-- Used By: api_Custom_BrowserCommunication
-- =============================================
IF NOT EXISTS (
  SELECT * 
  FROM   sys.columns 
  WHERE  object_id = OBJECT_ID(N'dp_Communications') 
         AND name = 'Communication_GUID'
)
BEGIN

	ALTER TABLE dp_Communications add Communication_GUID UniqueIdentifier NOT NULL default newid() with values

END