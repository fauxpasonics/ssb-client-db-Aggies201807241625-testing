CREATE TABLE [amy].[rpt_seatrecon_tb]
(
[adnumber] [int] NULL,
[accountname] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sporttype] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ticket Total] [int] NULL,
[CAP] [money] NULL,
[Annual] [money] NULL,
[CAPCredit] [money] NULL,
[AnnualCredit] [money] NULL,
[Advantage Adjusted CAP Pledge] [money] NOT NULL,
[Adv CAP Pledge] [money] NOT NULL,
[Adv CAP Receipt AMount] [money] NOT NULL,
[Adv CAP Match Pledge] [money] NOT NULL,
[Adv CAP Match Receipt] [money] NOT NULL,
[Adv CAP Credit] [money] NOT NULL,
[Advantage Adjusted Annual Pledge] [money] NOT NULL,
[Adv Annual  Pledge] [money] NOT NULL,
[Adv Annual Receipt] [money] NOT NULL,
[Adv Annual Match Pledge] [money] NOT NULL,
[Adv Annual Match Receipt] [money] NOT NULL,
[Adv Annual Credit] [money] NOT NULL,
[scheduledpayments] [money] NULL,
[capital_ada_credit_amount] [money] NULL,
[ticketpaidpercent] [numeric] (38, 19) NULL,
[ticketscheduledpercent] [numeric] (38, 19) NULL,
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
[min_annual_receipt_date] [datetime] NULL,
[Ticketyear] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TixEventLookupID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
[ordergroupbottomlinegrandtotal] [numeric] (19, 4) NULL,
[ordergrouptotalpaymentscleared] [numeric] (19, 4) NULL,
[ordergrouptotalpaymentsonhold] [numeric] (19, 4) NULL,
[vtxcusttype] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[renewal_date] [date] NULL,
[newticket] [int] NULL,
[min_ticketpaymentdate] [datetime] NULL,
[Renewable] [int] NULL,
[Renewed] [int] NULL,
[Cancelled] [int] NULL,
[AddedItems] [int] NULL,
[NewItems] [int] NULL,
[renewal_complete] [int] NULL,
[pacseason] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pacitem] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
CREATE NONCLUSTERED INDEX [rpt_seatrecon_tb_ind_adnumber_ticketyear] ON [amy].[rpt_seatrecon_tb] ([adnumber], [Ticketyear])
GO
CREATE NONCLUSTERED INDEX [nci_wi_rpt_seatrecon_tb_C8DA0FEAB1977F114D156C47FA009EF0] ON [amy].[rpt_seatrecon_tb] ([email], [TixEventLookupID])
GO
CREATE NONCLUSTERED INDEX [rpt_seatrecon_tb_ind_pac] ON [amy].[rpt_seatrecon_tb] ([pacseason], [pacitem])
GO
CREATE NONCLUSTERED INDEX [rpt_seatrecon_tb_ind_sportid_ticketyear] ON [amy].[rpt_seatrecon_tb] ([sporttype], [Ticketyear])
GO
CREATE NONCLUSTERED INDEX [nci_wi_rpt_seatrecon_tb_11695B53111B8C14514EA84CD2E16F9C] ON [amy].[rpt_seatrecon_tb] ([sporttype], [Ticketyear]) INCLUDE ([adnumber], [Adv Annual  Pledge], [Adv Annual Credit], [Adv Annual Match Pledge], [Adv Annual Match Receipt], [Adv Annual Receipt], [Adv CAP Match Pledge], [Adv CAP Match Receipt], [Adv CAP Pledge], [Adv CAP Receipt AMount], [Annual], [AnnualScheduledPayments], [CapStillDue], [min_annual_receipt_date], [newticket], [ordergroupbottomlinegrandtotal], [ordergrouptotalpaymentscleared], [ordergrouptotalpaymentsonhold], [renewal_complete], [renewal_date], [Renewed], [Ticket Total], [ticketpaidpercent])
GO
CREATE NONCLUSTERED INDEX [rpt_seatrecon_tb_ind_sportid_ticketyear_adnumber] ON [amy].[rpt_seatrecon_tb] ([sporttype], [Ticketyear], [adnumber], [accountname])
GO
CREATE NONCLUSTERED INDEX [nci_wi_rpt_seatrecon_tb_D911CFF638E371EED2B8A87551629771] ON [amy].[rpt_seatrecon_tb] ([Ticketyear]) INCLUDE ([accountname], [ADA], [adnumber], [Adv Annual  Pledge], [Adv Annual Credit], [Adv Annual Match Pledge], [Adv Annual Match Receipt], [Adv Annual Receipt], [Adv CAP Credit], [Adv CAP Match Pledge], [Adv CAP Match Receipt], [Adv CAP Pledge], [Adv CAP Receipt AMount], [Advantage Adjusted Annual Pledge], [Advantage Adjusted CAP Pledge], [ALL_TICKETS], [Annual], [AnnualCredit], [annualdifference], [annualrecdifference], [AnnualScheduledPayments], [CAP], [CAP_100], [cap_20], [CAP_40], [CAP_60], [CAP_80], [CAP_DUE], [CAP_OTHER], [CAPCredit], [capdifference], [capital_ada_credit_amount], [caprecdifference], [CapStillDue], [Comp], [DC], [E], [EC], [email], [Faculty], [FacultyAD], [KFCScheduledPayments], [lastupdated], [Lettermen], [LinealTransfer], [min_annual_receipt_date], [min_ticketpaymentdate], [newticket], [ordergroupbottomlinegrandtotal], [ordergrouptotalpaymentscleared], [ordergrouptotalpaymentsonhold], [ordernumber], [renewal_date], [scheduledpayments], [seatlastupdated], [SingleSeason], [sporttype], [status], [Ticket Count], [Ticket Total], [ticketpaidpercent], [ticketscheduledpercent], [TixEventLookupID], [UO], [UO-R], [updatedate], [vtxcusttype], [ZC E])
GO
CREATE NONCLUSTERED INDEX [nci_wi_rpt_seatrecon_tb_4EC0560C228153D8B1D0AE0BB2A90E3C] ON [amy].[rpt_seatrecon_tb] ([Ticketyear]) INCLUDE ([accountname], [ADA], [adnumber], [Adv Annual  Pledge], [Adv Annual Credit], [Adv Annual Match Pledge], [Adv Annual Match Receipt], [Adv Annual Receipt], [Adv CAP Credit], [Adv CAP Match Pledge], [Adv CAP Match Receipt], [Adv CAP Pledge], [Adv CAP Receipt AMount], [Advantage Adjusted Annual Pledge], [Advantage Adjusted CAP Pledge], [ALL_TICKETS], [Annual], [AnnualCredit], [annualdifference], [annualrecdifference], [AnnualScheduledPayments], [CAP], [CAP_100], [cap_20], [CAP_40], [CAP_60], [CAP_80], [CAP_DUE], [CAP_OTHER], [CAPCredit], [capdifference], [capital_ada_credit_amount], [caprecdifference], [CapStillDue], [Comp], [DC], [E], [EC], [email], [Faculty], [FacultyAD], [KFCScheduledPayments], [lastupdated], [Lettermen], [LinealTransfer], [min_annual_receipt_date], [newticket], [ordergroupbottomlinegrandtotal], [ordergrouptotalpaymentscleared], [ordergrouptotalpaymentsonhold], [ordernumber], [renewal_date], [scheduledpayments], [seatlastupdated], [SingleSeason], [sporttype], [status], [Ticket Count], [Ticket Total], [ticketpaidpercent], [ticketscheduledpercent], [TixEventLookupID], [UO], [UO-R], [updatedate], [vtxcusttype], [ZC E])
GO
CREATE NONCLUSTERED INDEX [nci_wi_rpt_seatrecon_tb_AA50784E32072CBF289737AF690E05CE] ON [amy].[rpt_seatrecon_tb] ([Ticketyear], [sporttype]) INCLUDE ([accountname], [ADA], [AddedItems], [adnumber], [Adv Annual  Pledge], [Adv Annual Credit], [Adv Annual Match Pledge], [Adv Annual Match Receipt], [Adv Annual Receipt], [Adv CAP Credit], [Adv CAP Match Pledge], [Adv CAP Match Receipt], [Adv CAP Pledge], [Adv CAP Receipt AMount], [Advantage Adjusted Annual Pledge], [Advantage Adjusted CAP Pledge], [ALL_TICKETS], [Annual], [AnnualCredit], [annualdifference], [annualrecdifference], [AnnualScheduledPayments], [Cancelled], [CAP], [CAP_100], [cap_20], [CAP_40], [CAP_60], [CAP_80], [CAP_DUE], [CAP_OTHER], [CAPCredit], [capdifference], [capital_ada_credit_amount], [caprecdifference], [CapStillDue], [Comp], [DC], [E], [EC], [email], [Faculty], [FacultyAD], [KFCScheduledPayments], [lastupdated], [Lettermen], [LinealTransfer], [min_annual_receipt_date], [min_ticketpaymentdate], [NewItems], [newticket], [ordergroupbottomlinegrandtotal], [ordergrouptotalpaymentscleared], [ordergrouptotalpaymentsonhold], [ordernumber], [Renewable], [renewal_complete], [renewal_date], [Renewed], [scheduledpayments], [seatlastupdated], [SingleSeason], [status], [Ticket Count], [Ticket Total], [ticketpaidpercent], [ticketscheduledpercent], [TixEventLookupID], [UO], [UO-R], [updatedate], [vtxcusttype], [ZC E])
GO
CREATE NONCLUSTERED INDEX [rpt_seatrecon_tb_ind_tixeventlookupid] ON [amy].[rpt_seatrecon_tb] ([TixEventLookupID])
GO
CREATE NONCLUSTERED INDEX [idx_rpt_seatrecon_tb_tixeventlookupid_adnumber] ON [amy].[rpt_seatrecon_tb] ([TixEventLookupID], [adnumber])
GO
