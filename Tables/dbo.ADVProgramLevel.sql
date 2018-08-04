CREATE TABLE [dbo].[ADVProgramLevel]
(
[LevelID] [int] NOT NULL,
[ProgramID] [int] NULL,
[LevelName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MinAmount] [money] NULL,
[MaxAmount] [money] NULL,
[Year] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
