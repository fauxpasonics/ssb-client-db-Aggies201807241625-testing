CREATE TABLE [amy].[rpt_execdash_ticket_summary_tb]
(
[tixeventlookupid] [nvarchar] (48) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rptyear] [int] NULL,
[ordergroupbottomlinegrandtotal] [numeric] (38, 4) NULL,
[ordergrouppaymentbalance] [numeric] (38, 4) NULL,
[ordergrouptotalpaymentscleared] [numeric] (38, 4) NULL,
[YTDordergrouptotalpaymentscleared] [numeric] (38, 4) NULL,
[ordergrouptotalpaymentsonhold] [numeric] (38, 4) NULL,
[updatedate] [datetime] NOT NULL
)
GO
