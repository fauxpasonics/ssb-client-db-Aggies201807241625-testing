CREATE TABLE [amy].[rpt_seatrecon_test_newsuites]
(
[adnumber] [int] NULL,
[accountname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sporttype] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ticket Total] [int] NULL,
[CAP] [money] NULL,
[Annual] [money] NULL,
[CAPCredit] [money] NULL,
[AnnualCredit] [money] NULL,
[Advantage Adjusted CAP Pledge] [money] NULL,
[Adv CAP Pledge] [money] NULL,
[Adv CAP Receipt AMount] [money] NULL,
[Adv CAP Match Pledge] [money] NULL,
[Adv CAP Match Receipt] [money] NULL,
[Adv CAP Credit] [money] NULL,
[Advantage Adjusted Annual Pledge] [money] NULL,
[Adv Annual  Pledge] [money] NULL,
[Adv Annual Receipt] [money] NULL,
[Adv Annual Match Pledge] [money] NULL,
[Adv Annual Match Receipt] [money] NULL,
[Adv Annual Credit] [money] NULL,
[scheduledpayments] [money] NULL,
[capital_ada_credit_amount] [money] NULL,
[ticketpaidpercent] [numeric] (38, 6) NULL,
[ticketscheduledpercent] [numeric] (38, 6) NULL,
[capdifference] [money] NULL,
[annualdifference] [money] NULL,
[caprecdifference] [money] NULL,
[annualrecdifference] [money] NULL,
[ADA] [int] NULL,
[E] [int] NULL,
[EC] [int] NULL,
[ZC E] [int] NULL,
[Lettermen] [int] NULL,
[FacultyAD] [int] NULL,
[Faculty] [int] NULL,
[DC] [int] NULL,
[Comp] [int] NULL,
[UO] [int] NULL,
[UO-R] [int] NULL,
[SingleSeason] [int] NULL,
[Ticket Count] [int] NULL,
[ALL_TICKETS] [int] NULL,
[AnnualScheduledPayments] [money] NULL,
[KFCScheduledPayments] [money] NULL,
[min_annual_receipt_date] [int] NULL,
[Ticketyear] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TixEventLookupID] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[updatedate] [datetime] NOT NULL,
[cap_20] [int] NULL,
[CAP_40] [int] NULL,
[CAP_60] [int] NULL,
[CAP_80] [int] NULL,
[CAP_100] [int] NULL,
[CAP_OTHER] [int] NULL,
[CAP_DUE] [numeric] (38, 6) NULL,
[LinealTransfer] [int] NULL,
[CapStillDue] [numeric] (38, 6) NULL,
[ordernumber] [numeric] (10, 0) NULL,
[seatlastupdated] [datetime] NULL,
[lastupdated] [datetime] NOT NULL,
[ordergroupbottomlinegrandtotal] [numeric] (38, 4) NULL,
[ordergrouptotalpaymentscleared] [numeric] (38, 4) NULL,
[ordergrouptotalpaymentsonhold] [numeric] (38, 4) NULL,
[vtxcusttype] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
