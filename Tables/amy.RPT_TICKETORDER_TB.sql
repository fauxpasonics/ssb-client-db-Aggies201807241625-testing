CREATE TABLE [amy].[RPT_TICKETORDER_TB]
(
[accountnumber] [nvarchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastname] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[firstname] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fullname] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customerid] [numeric] (38, 10) NULL,
[ordergrouppaymentstatus] [smallint] NULL,
[ordergroupstatus] [smallint] NULL,
[tixeventlookupid] [nvarchar] (48) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixeventtitleshort] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ordergroupbottomlinegrandtotal] [numeric] (19, 4) NULL,
[ordergrouppaymentbalance] [numeric] (19, 4) NULL,
[ordergrouptotalpaymentscleared] [numeric] (19, 4) NULL,
[ordergrouptotalpaymentsonhold] [numeric] (19, 4) NULL,
[updatedate] [datetime] NOT NULL,
[ordernumber] [numeric] (10, 0) NULL
)
GO
CREATE NONCLUSTERED INDEX [nci_wi_RPT_TICKETORDER_TB_8089BF878299E4F7E7C7E07857C47E40] ON [amy].[RPT_TICKETORDER_TB] ([tixeventlookupid])
GO
CREATE NONCLUSTERED INDEX [nci_wi_RPT_TICKETORDER_TB_D579D71B78F22DB5467A3E0B4C7B76D4] ON [amy].[RPT_TICKETORDER_TB] ([tixeventlookupid]) INCLUDE ([ordergroupbottomlinegrandtotal], [ordergrouppaymentbalance], [ordergrouptotalpaymentscleared], [ordergrouptotalpaymentsonhold], [tixeventtitleshort])
GO
