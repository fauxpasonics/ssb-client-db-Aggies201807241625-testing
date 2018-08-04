CREATE TABLE [dbo].[ContactTransLineItems]
(
[PK] [int] NOT NULL,
[TransID] [int] NULL,
[ProgramID] [int] NULL,
[MatchProgramID] [int] NULL,
[TransAmount] [money] NOT NULL,
[MatchAmount] [money] NOT NULL,
[MatchingGift] [bit] NOT NULL,
[Renew] [bit] NOT NULL,
[Renewed] [bit] NOT NULL,
[Comments] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
ALTER TABLE [dbo].[ContactTransLineItems] ADD CONSTRAINT [PK_ContactTransLineItems_da1cc666-3873-497f-82de-124ef51c1f6a] PRIMARY KEY CLUSTERED  ([PK])
GO
CREATE NONCLUSTERED INDEX [IX_ProgramID] ON [dbo].[ContactTransLineItems] ([ProgramID], [TransID], [TransAmount])
GO
CREATE NONCLUSTERED INDEX [IX_TransID] ON [dbo].[ContactTransLineItems] ([TransID])
GO
CREATE NONCLUSTERED INDEX [idx_Nonclustered_ContactTransLineItems_ProgramID_MatchingGift] ON [dbo].[ContactTransLineItems] ([TransID], [TransAmount], [MatchAmount], [ProgramID], [MatchingGift])
GO
