CREATE TABLE [dbo].[ADVContactTransLineItems]
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
CREATE NONCLUSTERED INDEX [nci_wi_ADVContactTransLineItems_C969381642680729ABE30229128D70D6] ON [dbo].[ADVContactTransLineItems] ([MatchingGift], [TransID]) INCLUDE ([MatchAmount], [ProgramID], [TransAmount])
GO
CREATE NONCLUSTERED INDEX [nci_wi_ADVContactTransLineItems_B82138F7228484D5AC0111E12B126EA2] ON [dbo].[ADVContactTransLineItems] ([ProgramID], [MatchingGift]) INCLUDE ([MatchAmount], [TransAmount], [TransID])
GO
CREATE NONCLUSTERED INDEX [nci_wi_ADVContactTransLineItems_A01992C9CF73DEE592F4C6EB0A3186C7] ON [dbo].[ADVContactTransLineItems] ([TransID]) INCLUDE ([MatchAmount], [MatchingGift], [ProgramID], [TransAmount])
GO
