CREATE TABLE [src].[CD_ContactGUIDMerge]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[ETL_InsertDate] [datetime] NULL CONSTRAINT [DF_src_CD_ContactGUIDMerge_ETL_InsertDate] DEFAULT (getdate()),
[MergeId] [int] NOT NULL,
[ContactGUID_Winner] [uniqueidentifier] NULL,
[ContactGUID_Loser] [uniqueidentifier] NULL,
[MergeDate] [datetime] NULL
)
GO
ALTER TABLE [src].[CD_ContactGUIDMerge] ADD CONSTRAINT [PK_src_CD_ContactGUIDMerge_ID] PRIMARY KEY CLUSTERED  ([ID])
GO
