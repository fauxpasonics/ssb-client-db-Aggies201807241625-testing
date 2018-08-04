CREATE TABLE [amy].[seatdetail_individual_history]
(
[accountnumber] [nvarchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[categoryname] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixeventlookupid] [nvarchar] (48) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixeventtitleshort] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixeventid] [numeric] (10, 0) NULL,
[year] [int] NULL,
[seatpricecode] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[seatsection] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[seatrow] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[seatseat] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatid] [int] NULL,
[tixsyspricecode] [numeric] (10, 0) NULL,
[paid] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sent] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[paidpercent] [numeric] (38, 19) NULL,
[schpercent] [numeric] (38, 19) NULL,
[ordergroupbottomlinegrandtotal] [numeric] (19, 4) NULL,
[ordergrouptotalpaymentsonhold] [numeric] (19, 4) NULL,
[ordergrouptotalpaymentscleared] [numeric] (19, 4) NULL,
[update_date] [datetime] NOT NULL,
[tixseatlastupdate] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[create_date] [datetime] NULL,
[cancel_ind] [bit] NULL,
[cancel_date] [datetime] NULL,
[seatdetail_individual_history_id] [int] NOT NULL IDENTITY(1, 1),
[CAPTERMSTARTDATE] [datetime] NULL,
[CAPTERMSTARTYEAR] [int] NULL,
[CAP_Percent_Owe_ToDate] [numeric] (10, 2) NULL,
[lineal_transfer_release_ind] [bit] NULL,
[lineal_transfer_received_ind] [bit] NULL,
[lineal_transfer_date] [datetime] NULL,
[lineal_transfer_parent] [int] NULL,
[ticket_start_date] [datetime] NULL,
[ticket_start_year] [int] NULL,
[lineal_transfer_parent_acct] [int] NULL,
[relocation_release_ind] [bit] NULL,
[relocation_start_ind] [bit] NULL,
[relocation_date] [datetime] NULL,
[relocation_parent_id] [int] NULL,
[seatareaid] [int] NULL,
[seatregionid] [int] NULL,
[SeatTerm] [int] NULL,
[ordernumber] [numeric] (10, 0) NULL,
[seatlastupdated] [datetime] NULL,
[renewal_date] [date] NULL,
[renewal_order] [bit] NULL,
[ordergroupdate] [datetime2] (6) NULL,
[ordergrouplastupdated] [datetime2] (6) NULL,
[renewal_ticket] [bit] NULL,
[new_ticket] [bit] NULL,
[creditamount] [money] NULL,
[ticketvalue] [numeric] (19, 4) NULL,
[ticketpaid] [numeric] (19, 4) NULL,
[tixseatgroupid] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatgrouppricelevel] [numeric] (10, 0) NULL,
[tixseatofferid] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[addonticket] [bit] NULL,
[min_ticketpaymentdate] [date] NULL,
[renewal_complete] [int] NULL,
[annualpaidperseat] [money] NULL,
[scheduledpaidperseat] [money] NULL,
[totalpaidperseat] [money] NULL,
[annualpaidpercent] [numeric] (18, 0) NULL,
[annualscheduledpercent] [numeric] (18, 0) NULL,
[pacseason] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pacitem] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[i_pl] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[seq] [int] NULL
)
GO
CREATE NONCLUSTERED INDEX [seatdetail_individual_history_01] ON [amy].[seatdetail_individual_history] ([accountnumber], [tixeventlookupid], [year])
GO
CREATE NONCLUSTERED INDEX [seatdetail_individual_history_02] ON [amy].[seatdetail_individual_history] ([accountnumber], [tixeventlookupid], [year], [seatsection], [seatrow], [seatseat])
GO
CREATE NONCLUSTERED INDEX [idx_Nonclustered_seatdetail_individual_history_cancel_date] ON [amy].[seatdetail_individual_history] ([cancel_date])
GO
CREATE NONCLUSTERED INDEX [nci_wi_seatdetail_individual_history_376787A531C6EF30E14EF949B84F98AE] ON [amy].[seatdetail_individual_history] ([cancel_ind], [tixeventlookupid]) INCLUDE ([accountnumber], [paid], [relocation_parent_id], [seatdetail_individual_history_id], [seatrow], [seatseat], [seatsection])
GO
CREATE NONCLUSTERED INDEX [nci_wi_seatdetail_individual_history_A97FD3C65BC7CEE1D7BAD2665E0CFD2D] ON [amy].[seatdetail_individual_history] ([cancel_ind], [tixeventlookupid]) INCLUDE ([creditamount], [seatareaid], [seatpricecode], [seatrow], [seatseat], [seatsection])
GO
CREATE NONCLUSTERED INDEX [idx_Nonclustered_seatdetail_individual_history_create_date] ON [amy].[seatdetail_individual_history] ([create_date])
GO
CREATE NONCLUSTERED INDEX [seatdetail_individual_history_pacevent_ind01] ON [amy].[seatdetail_individual_history] ([pacseason], [pacitem])
GO
CREATE NONCLUSTERED INDEX [seatdetail_individual_history_pacevent_ind02] ON [amy].[seatdetail_individual_history] ([pacseason], [pacitem], [accountnumber])
GO
CREATE NONCLUSTERED INDEX [idx_Nonclustered_seatdetail_individual_history_relocation_date] ON [amy].[seatdetail_individual_history] ([relocation_date])
GO
CREATE NONCLUSTERED INDEX [nci_wi_seatdetail_individual_history_BDE56C0FAD82DD6415CFABC354457D68] ON [amy].[seatdetail_individual_history] ([seatareaid], [year]) INCLUDE ([accountnumber])
GO
CREATE NONCLUSTERED INDEX [seatdetail_individual_history_ind01] ON [amy].[seatdetail_individual_history] ([seatdetail_individual_history_id])
GO
CREATE NONCLUSTERED INDEX [nci_wi_seatdetail_individual_history_2E6006C783588B8A0EA5CD747EBCD1AC] ON [amy].[seatdetail_individual_history] ([tixeventlookupid], [addonticket]) INCLUDE ([accountnumber], [relocation_release_ind], [renewal_date], [renewal_ticket], [seatpricecode], [seatregionid], [tixseatid])
GO
CREATE NONCLUSTERED INDEX [nci_wi_seatdetail_individual_history_61D8662811D1E41B60DD1174B7E8A998] ON [amy].[seatdetail_individual_history] ([tixeventlookupid], [cancel_ind], [seatareaid]) INCLUDE ([accountnumber], [addonticket], [CAP_Percent_Owe_ToDate], [lineal_transfer_received_ind], [min_ticketpaymentdate], [new_ticket], [ordergroupbottomlinegrandtotal], [ordergrouptotalpaymentscleared], [ordergrouptotalpaymentsonhold], [ordernumber], [paidpercent], [relocation_release_ind], [relocation_start_ind], [renewal_date], [renewal_ticket], [schpercent], [seatlastupdated], [seatpricecode])
GO
CREATE NONCLUSTERED INDEX [nci_wi_seatdetail_individual_history_EAE0565598FE5471EEA6D2CF1FCE47F8] ON [amy].[seatdetail_individual_history] ([tixeventlookupid], [cancel_ind], [seatareaid]) INCLUDE ([accountnumber], [cancel_date], [CAP_Percent_Owe_ToDate], [CAPTERMSTARTDATE], [CAPTERMSTARTYEAR], [categoryname], [create_date], [lineal_transfer_date], [lineal_transfer_received_ind], [new_ticket], [ordergroupbottomlinegrandtotal], [ordergroupdate], [ordergrouplastupdated], [ordergrouptotalpaymentscleared], [ordergrouptotalpaymentsonhold], [ordernumber], [paid], [paidpercent], [relocation_date], [renewal_date], [renewal_order], [renewal_ticket], [schpercent], [seatdetail_individual_history_id], [seatlastupdated], [seatpricecode], [seatregionid], [seatrow], [seatseat], [seatsection], [SeatTerm], [sent], [tixeventid], [tixeventtitleshort], [tixseatid], [tixseatlastupdate], [tixsyspricecode], [year])
GO
CREATE NONCLUSTERED INDEX [nci_wi_seatdetail_individual_history_9C59E10365E2FD97831C9D7B55EBFF95] ON [amy].[seatdetail_individual_history] ([tixeventlookupid], [relocation_release_ind]) INCLUDE ([accountnumber], [cancel_date], [cancel_ind], [categoryname], [create_date], [creditamount], [lineal_transfer_received_ind], [lineal_transfer_release_ind], [ordergroupbottomlinegrandtotal], [ordergroupdate], [ordergrouplastupdated], [ordergrouptotalpaymentscleared], [ordergrouptotalpaymentsonhold], [ordernumber], [paid], [paidpercent], [relocation_start_ind], [schpercent], [seatpricecode], [seatrow], [seatseat], [seatsection], [sent], [ticketpaid], [ticketvalue], [tixeventid], [tixeventtitleshort], [tixseatgroupid], [tixseatgrouppricelevel], [tixseatid], [tixseatlastupdate], [tixseatofferid], [tixsyspricecode], [year])
GO
CREATE NONCLUSTERED INDEX [idx_Nonclustered_seatdetail_individual_history_update_date] ON [amy].[seatdetail_individual_history] ([update_date])
GO
