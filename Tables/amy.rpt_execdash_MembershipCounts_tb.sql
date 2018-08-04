CREATE TABLE [amy].[rpt_execdash_MembershipCounts_tb]
(
[Year] [nvarchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[levelname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[minamount] [money] NULL,
[maxamount] [numeric] (20, 4) NULL,
[YTD_cnt] [int] NULL,
[update_date] [datetime] NOT NULL
)
GO
