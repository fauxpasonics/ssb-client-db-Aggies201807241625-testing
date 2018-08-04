CREATE TABLE [amy].[rpt_FB_order_list_tb]
(
[sporttype] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ticketyear] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[accountnumber] [nvarchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ordergroupbottomlinegrandtotal] [numeric] (19, 4) NULL,
[ordergrouptotalpaymentsonhold] [numeric] (19, 4) NULL,
[ordergrouptotalpaymentscleared] [numeric] (19, 4) NULL,
[ordergrouppaymentbalance] [numeric] (19, 4) NULL,
[ordernumber] [numeric] (10, 0) NULL,
[Parking] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Bowl] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Away] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Home] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Season] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Arkansas] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VeritixDonations] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[updatedate] [datetime] NOT NULL
)
GO
CREATE NONCLUSTERED INDEX [rpt_FB_order_list_tb_ind01] ON [amy].[rpt_FB_order_list_tb] ([sporttype], [ticketyear])
GO
CREATE NONCLUSTERED INDEX [rpt_FB_order_list_tb_ind02] ON [amy].[rpt_FB_order_list_tb] ([sporttype], [ticketyear], [accountnumber])
GO
