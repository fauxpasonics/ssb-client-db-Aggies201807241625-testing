CREATE TABLE [dbo].[ADVHistoricalPriorityPoints2]
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
[EntryDate_Date] [date] NOT NULL
)
GO
ALTER TABLE [dbo].[ADVHistoricalPriorityPoints2] ADD CONSTRAINT [PK_HistoricalPriorityPoints2] PRIMARY KEY NONCLUSTERED  ([ContactID], [EntryDate_Date])
GO
