CREATE TABLE [mdm].[CD_ContactGUIDMerge]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[ETL_InsertDate] [datetime] NULL CONSTRAINT [DF_CD_ContactGUIDMerge_ETL_InsertDate] DEFAULT (getdate()),
[ETL_ProcessedDate] [datetime] NULL,
[MergeId] [int] NOT NULL,
[ContactGUID_Winner] [uniqueidentifier] NULL,
[ContactGUID_Loser] [uniqueidentifier] NULL,
[MergeDate] [datetime] NULL
)
GO
ALTER TABLE [mdm].[CD_ContactGUIDMerge] ADD CONSTRAINT [PK_CD_ContactGUIDMerge_ID] PRIMARY KEY CLUSTERED  ([ID])
GO
CREATE NONCLUSTERED INDEX [IX_CD_ContactGUIDMerge_ETL_ProcessedDate] ON [mdm].[CD_ContactGUIDMerge] ([ETL_ProcessedDate] DESC)
GO
CREATE NONCLUSTERED INDEX [IX_CD_ContactGUIDMerge_MergeDate] ON [mdm].[CD_ContactGUIDMerge] ([MergeDate] DESC)
GO
CREATE NONCLUSTERED INDEX [IX_CD_ContactGUIDMerge_MergeId] ON [mdm].[CD_ContactGUIDMerge] ([MergeId] DESC)
GO
