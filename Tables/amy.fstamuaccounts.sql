CREATE TABLE [amy].[fstamuaccounts]
(
[account_id] [numeric] (18, 0) NULL,
[first_name] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_name] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[work_phone_number] [numeric] (18, 0) NULL,
[home_phone_number] [numeric] (18, 0) NULL,
[mobile_phone_number] [numeric] (18, 0) NULL,
[birthdate] [datetime] NULL,
[account_created_datetime] [datetime] NULL,
[update_datetime] [datetime] NULL,
[load_datetime] [datetime] NULL
)
GO
