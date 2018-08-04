CREATE TABLE [dbo].[ADVHistoricalPriorityPoints]
(
[ContactID] [int] NOT NULL,
[EntryDate] [datetime] NOT NULL,
[Rank] [int] NULL,
[curr_yr_credits] [money] NULL,
[curr_yr_pledges] [money] NULL,
[curr_yr_receipts] [money] NULL,
[prev_yr_credits] [money] NULL,
[prev_yr_pledges] [money] NULL,
[prev_yr_receipts] [money] NULL,
[curr_yr_cash_pts] [float] NULL,
[prev_yr_cash_pts] [float] NULL,
[accrual_pts] [float] NULL,
[linked_ppts] [float] NULL,
[linked_ppts_given_up] [float] NULL,
[accrual_basis_ppts] [float] NULL,
[cash_basis_ppts] [float] NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
ALTER TABLE [dbo].[ADVHistoricalPriorityPoints] ADD CONSTRAINT [PK_HistoricalPriorityPoints_b3cc8640-66fa-4e3b-bff9-fdf2b97b53cb] PRIMARY KEY CLUSTERED  ([ContactID], [EntryDate])
GO
CREATE NONCLUSTERED INDEX [idx_Nonclustered_HistoricalPriorityPoints_EntryDate] ON [dbo].[ADVHistoricalPriorityPoints] ([EntryDate] DESC)
GO
