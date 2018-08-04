CREATE TABLE [amy].[ath_stg_shop]
(
[cust_id] [int] NULL,
[cust_fullname] [nvarchar] (53) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cust_fname] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cust_lname] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cust_email] [nvarchar] (73) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cust_phone] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cust_last_login_date] [datetime] NULL,
[cust_is_guest] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[order_count] [int] NULL
)
GO
