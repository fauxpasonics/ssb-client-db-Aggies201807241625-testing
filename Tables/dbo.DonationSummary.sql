CREATE TABLE [dbo].[DonationSummary]
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
ALTER TABLE [dbo].[DonationSummary] ADD CONSTRAINT [PK_DonorStatistics_3d85a352-c5f1-4e96-99e1-450abe9ef32d] PRIMARY KEY CLUSTERED  ([ContactID], [TransYear], [ProgramID])
GO
