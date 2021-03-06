CREATE TABLE [amy].[rpt_allfootball]
(
[adnumber] [int] NULL,
[accountname] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ticket Total] [int] NULL,
[CAP] [money] NULL,
[Annual] [money] NULL,
[CAPCredit] [money] NULL,
[AnnualCredit] [money] NULL,
[Adv CAP Pledge] [money] NOT NULL,
[Adv CAP Receipt AMount] [money] NOT NULL,
[Adv CAP Match Pledge] [money] NOT NULL,
[Adv CAP Match Receipt] [money] NOT NULL,
[Adv CAP Credit] [money] NOT NULL,
[Adv Annual  Pledge] [money] NOT NULL,
[Adv Annual Receipt] [money] NOT NULL,
[Adv Annual Match Pledge] [money] NOT NULL,
[Adv Annual Match Receipt] [money] NOT NULL,
[Adv Annual Credit] [money] NOT NULL,
[scheduledpayments] [money] NULL,
[AnnualScheduledPayments] [money] NULL,
[KFCScheduledPayments] [money] NULL,
[min_annual_receipt_date] [datetime] NULL,
[renewal_date] [date] NULL,
[email] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vtxcusttype] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ordergrouptotalpaymentsonhold] [numeric] (19, 4) NULL,
[ordergrouptotalpaymentscleared] [numeric] (19, 4) NULL,
[ordergroupbottomlinegrandtotal] [numeric] (19, 4) NULL,
[accountnumber] [nvarchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Grandtotal] [numeric] (38, 4) NULL,
[Scheduled] [numeric] (38, 4) NULL,
[Paid] [numeric] (38, 4) NULL,
[Balance] [numeric] (38, 4) NULL,
[OrderCount] [int] NULL,
[Parking] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Bowl] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Away] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Home] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Season] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Arkansas] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VeritixDonations] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EG_CapPledgeDifference] [money] NULL,
[EG_AnnualPledgeDifference] [money] NULL,
[EG_CurrentYearAnnualPastDue] [money] NULL,
[EG_ArkCurrentYearAnnualPastDue] [money] NULL,
[EG_TicketOrderPerPastDue] [numeric] (38, 19) NULL,
[CapStillDue] [numeric] (38, 6) NOT NULL,
[CAP_DUE] [numeric] (38, 6) NOT NULL,
[EG_CapDue] [int] NOT NULL,
[EG_AnnualDue] [int] NOT NULL,
[EG_TicketsDue] [int] NOT NULL,
[EG_ItemsDue] [numeric] (38, 4) NULL,
[TicketDueAmount] [numeric] (21, 4) NULL,
[DP_CAPReceiptwithCredits] [money] NULL,
[DP_AnnualReceiptwithCredits] [money] NULL,
[DP_ArkAnnualReceiptwithCredits] [money] NULL,
[arkadnumber] [int] NULL,
[ArkAnnual] [money] NOT NULL,
[Ark Adv Annual Receipt] [money] NOT NULL,
[Ark Adv Annual Match Pledge] [money] NOT NULL,
[ArkAnnualScheduledPayments] [money] NOT NULL,
[Ark Adv Annual Credit] [money] NOT NULL,
[ordernumber] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sporttype] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ticketyear] [int] NULL
)
GO
CREATE NONCLUSTERED INDEX [rpt_allfootball_ticketyear_idx] ON [amy].[rpt_allfootball] ([ticketyear])
GO
CREATE NONCLUSTERED INDEX [rpt_allfootball_ticketyear_adnumber_accountname_idx] ON [amy].[rpt_allfootball] ([ticketyear], [accountname])
GO
CREATE NONCLUSTERED INDEX [rpt_allfootball_ticketyear_adnumber_idx] ON [amy].[rpt_allfootball] ([ticketyear], [adnumber])
GO
CREATE NONCLUSTERED INDEX [rpt_allfootball_ticketyear_adnumber_pastdue_idx] ON [amy].[rpt_allfootball] ([ticketyear], [EG_ItemsDue])
GO
