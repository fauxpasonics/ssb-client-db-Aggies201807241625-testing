CREATE TABLE [amy].[ed_ticket_event_summary]
(
[tixeventid] [numeric] (10, 0) NULL,
[tixeventlookupid] [nvarchar] (48) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixeventtitleshort] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixeventinitdate] [datetime2] (6) NULL,
[Yearcategory] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[category] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubCategory] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CategoryAlT] [nvarchar] (301) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubCategoryALT] [nvarchar] (301) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ordergroupbottomlinegrandtotal] [numeric] (38, 4) NULL,
[ordergrouppaymentbalance] [numeric] (38, 4) NULL,
[ordergrouptotalpaymentscleared] [numeric] (38, 4) NULL,
[ordergrouptotalpaymentsonhold] [numeric] (38, 4) NULL,
[update_date] [datetime] NOT NULL
)
GO
