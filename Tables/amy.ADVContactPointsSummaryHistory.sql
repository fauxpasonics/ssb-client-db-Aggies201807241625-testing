CREATE TABLE [amy].[ADVContactPointsSummaryHistory]
(
[contactid] [int] NOT NULL,
[entrydate] [datetime] NOT NULL,
[cash_basis_ppts] [float] NULL,
[linked_ppts_given_up] [float] NULL,
[linked_ppts] [float] NULL,
[Rank] [int] NULL,
[Points_values] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[updatedate] [date] NULL
)
GO
CREATE NONCLUSTERED INDEX [nci_wi_ADVContactPointsSummaryHistory_2D3FADA39571EFE8306BC2E4418085F0] ON [amy].[ADVContactPointsSummaryHistory] ([contactid])
GO
