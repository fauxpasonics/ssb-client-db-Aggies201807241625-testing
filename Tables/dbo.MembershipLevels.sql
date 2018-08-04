CREATE TABLE [dbo].[MembershipLevels]
(
[MembID] [int] NOT NULL,
[LevelID] [int] NOT NULL,
[LevelName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MinAmount] [money] NULL,
[MaxAmount] [money] NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
ALTER TABLE [dbo].[MembershipLevels] ADD CONSTRAINT [PK_MembershipLevels_eb6dcfd1-f03f-4d53-9bed-efdd219ab8f3] PRIMARY KEY CLUSTERED  ([LevelID])
GO
CREATE NONCLUSTERED INDEX [IX_MembershipLevels] ON [dbo].[MembershipLevels] ([MembID], [LevelID])
GO
