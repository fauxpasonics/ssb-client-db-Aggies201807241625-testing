CREATE TABLE [dbo].[ADVDonationSummary]
(
[ContactID] [int] NOT NULL,
[TransYear] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProgramID] [int] NOT NULL,
[CashPledges] [money] NOT NULL,
[CashReceipts] [money] NOT NULL,
[GIKPledges] [money] NOT NULL,
[GIKReceipts] [money] NOT NULL,
[MatchPledges] [money] NOT NULL,
[MatchReceipts] [money] NOT NULL,
[Credits] [money] NOT NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
CREATE NONCLUSTERED INDEX [nci_wi_ADVDonationSummary_C275B7B014F3D7236346329230A0EE26] ON [dbo].[ADVDonationSummary] ([ContactID], [TransYear]) INCLUDE ([CashPledges], [CashReceipts], [GIKPledges], [GIKReceipts], [MatchPledges], [MatchReceipts])
GO
