CREATE TABLE [ods].[FS_forwards]
(
[transfer_action_id] [bigint] NULL,
[ticket_id] [bigint] NULL,
[event_owner_id] [bigint] NULL,
[event_id] [bigint] NULL,
[vt_event_id] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[from_account_id] [bigint] NULL,
[to_account_id] [bigint] NULL,
[to_email_address] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ticket_state] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[forward_type] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tickets] [int] NULL,
[forward_date] [datetime2] NULL,
[recall_date] [datetime2] NULL,
[update_datetime] [datetime2] NULL,
[transfer_id] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL,
[ETL_Sync_UpdatedDate] [datetime] NULL
)
GO
