CREATE TABLE [dbo].[ContactTransHeader]
(
[TransID] [int] NOT NULL,
[ContactID] [int] NULL,
[TransYear] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TransDate] [datetime] NULL,
[TransGroup] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TransType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MatchingAcct] [int] NULL,
[MatchingTransID] [int] NULL,
[PaymentType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CheckNo] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CardType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CardNo] [varchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExpireDate] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CardHolderName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CardHolderAddress] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CardHolderZip] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AuthCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AuthTransID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[notes] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[renew] [bit] NOT NULL,
[EnterDateTime] [datetime] NULL,
[EnterByUser] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BatchRefNo] [int] NULL,
[ReceiptID] [int] NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
ALTER TABLE [dbo].[ContactTransHeader] ADD CONSTRAINT [PK_ContactTransHeader_9683edc6-119f-45f8-9927-cc4f77916403] PRIMARY KEY CLUSTERED  ([TransID])
GO
CREATE NONCLUSTERED INDEX [IX_BatchRefNo] ON [dbo].[ContactTransHeader] ([BatchRefNo])
GO
CREATE NONCLUSTERED INDEX [IX_ContactID] ON [dbo].[ContactTransHeader] ([ContactID], [TransType], [TransID], [TransYear])
GO
CREATE NONCLUSTERED INDEX [IX_EnterDateTime] ON [dbo].[ContactTransHeader] ([EnterDateTime])
GO
CREATE NONCLUSTERED INDEX [IX_MatchingAcct] ON [dbo].[ContactTransHeader] ([MatchingAcct])
GO
CREATE NONCLUSTERED INDEX [idx_Nonclustered_ContactTransHeader_TransYear_TransDate] ON [dbo].[ContactTransHeader] ([TransID], [ContactID], [TransType], [TransYear], [TransDate])
GO
CREATE NONCLUSTERED INDEX [idx_Nonclustered_ContactTransHeader_TransType_ReceiptID] ON [dbo].[ContactTransHeader] ([TransType], [ReceiptID])
GO
CREATE NONCLUSTERED INDEX [IX_TransType] ON [dbo].[ContactTransHeader] ([TransType], [TransID], [ContactID], [TransYear])
GO
