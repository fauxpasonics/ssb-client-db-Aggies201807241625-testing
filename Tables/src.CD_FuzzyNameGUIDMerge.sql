CREATE TABLE [src].[CD_FuzzyNameGUIDMerge]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[ETL_InsertDate] [datetime] NULL CONSTRAINT [DF_src_CD_FuzzyNameGUIDMerge_ETL_InsertDate] DEFAULT (getdate()),
[MergeId] [int] NOT NULL,
[FuzzyNameGUID_Winner] [uniqueidentifier] NULL,
[FuzzyNameGUID_Loser] [uniqueidentifier] NULL,
[MergeDate] [datetime] NULL
)
GO
ALTER TABLE [src].[CD_FuzzyNameGUIDMerge] ADD CONSTRAINT [PK_src_CD_FuzzyNameGUIDMerge_ID] PRIMARY KEY CLUSTERED  ([ID])
GO
