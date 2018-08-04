CREATE TABLE [amy].[seatdetail_individual_tmp]
(
[accountnumber] [nvarchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[categoryname] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixeventlookupid] [nvarchar] (48) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixeventtitleshort] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
[ordernumber] [numeric] (10, 0) NULL,
[ordergroupdate] [datetime2] (6) NULL,
[ordergrouplastupdated] [datetime2] (6) NULL,
[tixeventid] [numeric] (10, 0) NULL,
[tixseatgroupid] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatgrouppricelevel] [numeric] (10, 0) NULL,
[tixseatofferid] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ticketvalue] [numeric] (19, 4) NULL,
[ticketpaid] [numeric] (19, 4) NULL
)
GO
CREATE NONCLUSTERED INDEX [idx_Nonclustered_seatdetail_individual_tmp_1] ON [amy].[seatdetail_individual_tmp] ([accountnumber], [seatpricecode], [seatsection], [seatrow], [seatseat], [tixeventlookupid])
GO
CREATE NONCLUSTERED INDEX [seatdetail_individual_tmp_02] ON [amy].[seatdetail_individual_tmp] ([accountnumber], [tixeventlookupid], [year], [seatsection], [seatrow], [seatseat])
GO
CREATE NONCLUSTERED INDEX [nci_wi_seatdetail_individual_tmp_4D8D32D0E420956FB4591F37CE7BC334] ON [amy].[seatdetail_individual_tmp] ([tixeventlookupid]) INCLUDE ([accountnumber], [categoryname], [ordergroupbottomlinegrandtotal], [ordergroupdate], [ordergrouplastupdated], [ordergrouptotalpaymentscleared], [ordergrouptotalpaymentsonhold], [ordernumber], [paid], [paidpercent], [schpercent], [seatpricecode], [seatrow], [seatseat], [seatsection], [sent], [ticketpaid], [ticketvalue], [tixeventid], [tixeventtitleshort], [tixseatgroupid], [tixseatgrouppricelevel], [tixseatid], [tixseatlastupdate], [tixseatofferid], [tixsyspricecode], [year])
GO
