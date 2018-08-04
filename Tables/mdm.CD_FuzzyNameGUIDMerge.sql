CREATE TABLE [mdm].[CD_FuzzyNameGUIDMerge]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[ETL_InsertDate] [datetime] NULL CONSTRAINT [DF_CD_FuzzyNameGUIDMerge_ETL_InsertDate] DEFAULT (getdate()),
[ETL_ProcessedDate] [datetime] NULL,
[MergeId] [int] NOT NULL,
[FuzzyNameGUID_Winner] [uniqueidentifier] NULL,
[FuzzyNameGUID_Loser] [uniqueidentifier] NULL,
[MergeDate] [datetime] NULL
)
GO
ALTER TABLE [mdm].[CD_FuzzyNameGUIDMerge] ADD CONSTRAINT [PK_CD_FuzzyNameGUIDMerge_ID] PRIMARY KEY CLUSTERED  ([ID])
GO
CREATE NONCLUSTERED INDEX [IX_CD_FuzzyNameGUIDMerge_ETL_ProcessedDate] ON [mdm].[CD_FuzzyNameGUIDMerge] ([ETL_ProcessedDate] DESC)
GO
CREATE NONCLUSTERED INDEX [IX_CD_FuzzyNameGUIDMerge_MergeDate] ON [mdm].[CD_FuzzyNameGUIDMerge] ([MergeDate] DESC)
GO
CREATE NONCLUSTERED INDEX [IX_CD_FuzzyNameGUIDMerge_MergeId] ON [mdm].[CD_FuzzyNameGUIDMerge] ([MergeId] DESC)
GO
