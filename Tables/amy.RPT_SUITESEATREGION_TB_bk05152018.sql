CREATE TABLE [amy].[RPT_SUITESEATREGION_TB_bk05152018]
(
[percentdue] [numeric] (1, 1) NULL,
[adnumber] [int] NULL,
[accountname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[seatregionname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[seatregionid] [int] NULL,
[cap_amount] [money] NULL,
[annual_amount] [money] NULL,
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
[capdifference] [money] NULL,
[annualdifference] [money] NULL,
[caprecdifference] [money] NULL,
[annualrecdifference] [money] NULL,
[AnnualScheduledPayments] [money] NULL,
[KFCScheduledPayments] [money] NULL,
[min_annual_receipt_date] [datetime] NULL,
[capital_ada_credit_amount] [money] NULL,
[Sporttype] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ticketyear] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TixEventLookupID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[updatedate] [datetime] NOT NULL,
[ticketpaidpercent] [numeric] (19, 4) NULL,
[ticketscheduledpercent] [numeric] (19, 4) NULL,
[cap_20] [int] NULL,
[CAP_40] [int] NULL,
[CAP_60] [int] NULL,
[CAP_80] [int] NULL,
[CAP_100] [int] NULL,
[CAP_OTHER] [int] NULL,
[CAP_DUE] [int] NULL,
[LinealTransfer] [int] NULL,
[CapStillDue] [money] NULL,
[ordernumber] [numeric] (10, 0) NULL,
[seatlastupdated] [datetime] NULL,
[vtxcusttype] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[suite] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cappercent] [decimal] (10, 2) NULL,
[ordergroupbottomlinegrandtotal] [decimal] (10, 2) NULL,
[ordergrouptotalpaymentscleared] [decimal] (10, 2) NULL,
[ordergrouptotalpaymentsonhold] [decimal] (10, 2) NULL,
[parking] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
