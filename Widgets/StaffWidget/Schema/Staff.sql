/****** Object:  Table [dbo].[Staff]    Script Date: 4/17/2024 9:04:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Staff]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Staff](
	[Staff_ID] [int] IDENTITY(1,1) NOT NULL,
	[Domain_ID] [int] NOT NULL,
	[Contact_ID] [int] NOT NULL,
	[Title] [nvarchar](50) NOT NULL,
	[Start_Date] [datetime] NOT NULL,
	[End_Date] [datetime] NULL,
	[Show_Online] [bit] NOT NULL,
	[Online_Order] [tinyint] NOT NULL,
	[Facebook_URL] [dbo].[dp_URL] NULL,
 CONSTRAINT [PK_Staff] PRIMARY KEY CLUSTERED 
(
	[Staff_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_Staff_Start_Date]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Staff] ADD  CONSTRAINT [DF_Staff_Start_Date]  DEFAULT (getdate()) FOR [Start_Date]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_Staff_Show_Online]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Staff] ADD  CONSTRAINT [DF_Staff_Show_Online]  DEFAULT ((1)) FOR [Show_Online]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_Staff_Online_Order]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Staff] ADD  CONSTRAINT [DF_Staff_Online_Order]  DEFAULT ((10)) FOR [Online_Order]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Staff_Contacts]') AND parent_object_id = OBJECT_ID(N'[dbo].[Staff]'))
ALTER TABLE [dbo].[Staff]  WITH CHECK ADD  CONSTRAINT [FK_Staff_Contacts] FOREIGN KEY([Contact_ID])
REFERENCES [dbo].[Contacts] ([Contact_ID])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Staff_Contacts]') AND parent_object_id = OBJECT_ID(N'[dbo].[Staff]'))
ALTER TABLE [dbo].[Staff] CHECK CONSTRAINT [FK_Staff_Contacts]
GO
