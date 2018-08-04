CREATE TABLE [ods].[FS_scans]
(
[ticket_id] [bigint] NULL,
[redemption_action_id] [bigint] NULL,
[scan_date] [datetime2] NULL,
[tickets] [int] NULL,
[scan_status] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vt_event] [bigint] NULL,
[vt_zone] [bigint] NULL,
[vt_seat_group] [bigint] NULL,
[vt_seat_id] [bigint] NULL,
[redemption_method] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[event_owner_id] [bigint] NULL,
[scanner_name] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[scanner_sn] [bigint] NULL,
[scanner_mac] [bigint] NULL,
[account_id] [bigint] NULL,
[event_id] [bigint] NULL,
[external_event_config_primary] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[update_datetime] [datetime2] NULL,
[scan_id] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[context_id] [bigint] NULL,
[tix_event_id] [bigint] NULL,
[tix_eventzone_id] [bigint] NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL,
[ETL_Sync_UpdatedDate] [datetime] NULL
)
GO
