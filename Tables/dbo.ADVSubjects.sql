CREATE TABLE [dbo].[ADVSubjects]
(
[PK] [int] NOT NULL,
[SubjectText] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Inactive] [bit] NOT NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
