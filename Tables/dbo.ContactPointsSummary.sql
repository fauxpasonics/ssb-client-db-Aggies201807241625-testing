CREATE TABLE [dbo].[ContactPointsSummary]
(
[PK] [int] NOT NULL,
[ContactID] [int] NOT NULL,
[Description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Points] [float] NULL,
[Linked] [bit] NOT NULL,
[Value] [money] NULL
)
GO
ALTER TABLE [dbo].[ContactPointsSummary] ADD CONSTRAINT [PK_ContactPointsSummary_82dc1672-b32f-499b-95ef-cab1a172dc0b] PRIMARY KEY CLUSTERED  ([PK])
GO
