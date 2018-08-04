CREATE TABLE [dbo].[PacTranItem]
(
[OrganizationID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[PacTranID] [bigint] NOT NULL,
[PacTranItemID] [int] NOT NULL,
[ItemTypeCodeDbID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[ItemTypeCodeType] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[ItemTypeCodeSubtype] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[ItemTypeCode] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[AccountDbID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[AccountID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AllocationID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ReceivedDate] [datetime] NULL,
[AppliedPaymentAmt] [money] NULL,
[ChannelID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[Comments] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreditAmt] [money] NULL,
[DriveYear] [int] NULL,
[EmailRecipient] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FundTypeCodeDbID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[FundTypeCodeType] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[FundTypeCodeSubtype] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[FundTypeCode] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[FundMotiveID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[FundSourceID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[IsEmailConfirmationSent] [bit] NULL,
[IsPaymentScheduled] [bit] NULL,
[IsPledgeRolledOver] [bit] NULL,
[IsPrinted] [bit] NULL,
[IsRenewable] [bit] NULL,
[MatchedDonorAccountDbID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[MatchedDonorAccountID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MatchingPaymentDonorDbID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[MatchingPaymentDonorID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MatchingPledgeAmt] [money] NULL,
[Note] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PacBatchID] [bigint] NULL,
[PaymentAmt] [money] NULL,
[PledgeAmt] [money] NULL,
[ReceiptedDonorAccountID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReceiptedDonorDbID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[SolicitorID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SolicitorDbID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[SpecialEventID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[sys_CreateIP] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sys_CreateTS] [datetime] NULL,
[sys_CreateUser] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sys_Status] [int] NULL,
[sys_UpdateIP] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sys_UpdateTS] [datetime] NULL,
[sys_UpdateUser] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
ALTER TABLE [dbo].[PacTranItem] ADD CONSTRAINT [PK_dbo_PacTranItem] PRIMARY KEY CLUSTERED  ([OrganizationID], [PacTranID], [PacTranItemID], [ItemTypeCodeDbID], [ItemTypeCodeType], [ItemTypeCodeSubtype], [ItemTypeCode])
GO
CREATE NONCLUSTERED INDEX [IX_PacTranItem_accountid_YR] ON [dbo].[PacTranItem] ([AccountID], [DriveYear])
GO
CREATE NONCLUSTERED INDEX [nci_wi_PacTranItem_071A67FC6D830D3F72C604DD8632A59A] ON [dbo].[PacTranItem] ([DriveYear]) INCLUDE ([AccountID], [AllocationID], [CreditAmt], [MatchedDonorAccountID], [MatchingPledgeAmt], [PaymentAmt], [PledgeAmt])
GO
CREATE NONCLUSTERED INDEX [nci_wi_PacTranItem_2FBFE84325F1030746DE8C6450FCE538] ON [dbo].[PacTranItem] ([DriveYear]) INCLUDE ([AccountID], [AllocationID], [CreditAmt], [MatchedDonorAccountID], [MatchingPledgeAmt], [PaymentAmt], [PledgeAmt], [ReceivedDate])
GO
CREATE NONCLUSTERED INDEX [IX_dbo_PacTranItem_FundType] ON [dbo].[PacTranItem] ([FundTypeCodeDbID], [FundTypeCodeType], [FundTypeCodeSubtype], [FundTypeCode])
GO
CREATE NONCLUSTERED INDEX [IX_dbo_PacTranItem_ItemType] ON [dbo].[PacTranItem] ([ItemTypeCodeDbID], [ItemTypeCodeType], [ItemTypeCodeSubtype], [ItemTypeCode])
GO
CREATE NONCLUSTERED INDEX [IX_PacTranItem_MatchedDonorAccountID_YR] ON [dbo].[PacTranItem] ([MatchedDonorAccountID], [DriveYear])
GO
CREATE NONCLUSTERED INDEX [IX_PacTranItem_ReceiptedDonorAccountID_YR] ON [dbo].[PacTranItem] ([ReceiptedDonorAccountID], [DriveYear])
GO
