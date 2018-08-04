CREATE TABLE [dbo].[ADVMembershipLevels]
(
[MembID] [int] NOT NULL,
[LevelID] [int] NOT NULL,
[LevelName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MinAmount] [money] NULL,
[MaxAmount] [money] NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
