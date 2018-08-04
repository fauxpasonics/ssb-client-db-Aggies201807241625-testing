CREATE TABLE [ods].[FS_accounts]
(
[account_id] [bigint] NOT NULL,
[first_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[work_phone_number] [varchar] (90) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[home_phone_number] [varchar] (90) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mobile_phone_number] [varchar] (90) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[birthdate] [datetime2] NULL,
[account_created_datetime] [datetime2] NULL,
[update_datetime] [datetime2] NULL,
[load_datetime] [datetime2] NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL,
[ETL_Sync_UpdatedDate] [datetime] NULL
)
GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_ods__FS_accounts] ON [ods].[FS_accounts]
GO
