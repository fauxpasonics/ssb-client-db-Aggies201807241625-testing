CREATE TABLE [ods].[FS_emails]
(
[account_id] [bigint] NULL,
[email] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email_state] [int] NULL,
[update_datetime] [datetime2] NULL,
[account_email_id] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL,
[ETL_Sync_UpdatedDate] [datetime] NULL
)
GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_ods__FS_emails] ON [ods].[FS_emails]
GO
