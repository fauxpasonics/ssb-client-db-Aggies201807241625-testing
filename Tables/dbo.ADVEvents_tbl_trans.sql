CREATE TABLE [dbo].[ADVEvents_tbl_trans]
(
[id] [int] NOT NULL,
[contactid] [int] NULL,
[create_date] [datetime] NOT NULL,
[trans_date] [datetime] NULL,
[pmt_descr] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pmt_amount] [money] NULL,
[auth_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[resp_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[resp_text] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trans_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pmt_method] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cc_name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cc_addr] [nvarchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cc_zip] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cc_phone] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bank_acct] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bank_rout] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bank_acct_type] [int] NULL,
[programid] [int] NULL,
[cust_ip] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cc_city] [nvarchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cc_state] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cc_email] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bank_name] [nvarchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[company] [nvarchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acct_number] [int] NULL,
[recur] [bit] NOT NULL,
[trans_profile_id] [int] NULL,
[note] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[misc] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[transyear] [nvarchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[order_id] [int] NULL,
[monthly] [bit] NOT NULL,
[adv_post_date] [datetime] NULL,
[receiptbyid] [int] NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
CREATE NONCLUSTERED INDEX [nci_wi_ADVEvents_tbl_trans_2422946A3C9614296D31EC9CC0084002] ON [dbo].[ADVEvents_tbl_trans] ([resp_code], [resp_text], [programid]) INCLUDE ([contactid], [pmt_amount])
GO