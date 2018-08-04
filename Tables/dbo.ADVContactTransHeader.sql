CREATE TABLE [dbo].[ADVContactTransHeader]
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
CREATE NONCLUSTERED INDEX [nci_wi_ADVContactTransHeader_DD243B24F994D438D46C2F67DA381476] ON [dbo].[ADVContactTransHeader] ([ContactID], [TransYear]) INCLUDE ([PaymentType], [ReceiptID], [TransDate], [TransID], [TransType])
GO
CREATE NONCLUSTERED INDEX [nci_wi_ADVContactTransHeader_948DDAD62ED7D4B7B481B5FD7E193009] ON [dbo].[ADVContactTransHeader] ([TransID], [TransYear]) INCLUDE ([ContactID], [PaymentType], [TransDate], [TransType])
GO
CREATE NONCLUSTERED INDEX [nci_wi_ADVContactTransHeader_DECFB79D792F98385EFBB4B0B214D4DE] ON [dbo].[ADVContactTransHeader] ([TransType], [TransDate]) INCLUDE ([ContactID], [PaymentType], [TransID])
GO
CREATE NONCLUSTERED INDEX [nci_wi_ADVContactTransHeader_49641BF14F39AD6672ADA51C03F7D0CB] ON [dbo].[ADVContactTransHeader] ([TransYear]) INCLUDE ([ContactID], [TransDate], [TransID], [TransType])
GO
