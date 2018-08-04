CREATE TABLE [ods].[FS_events]
(
[event_id] [bigint] NOT NULL,
[name] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[name_short] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[opens_datetime] [datetime2] NULL,
[start_datetime] [datetime2] NULL,
[offer_ceiling_amount] [decimal] (19, 4) NULL,
[offer_ceiling_percent] [int] NULL,
[offer_floor_amount] [decimal] (19, 4) NULL,
[offer_floor_percent] [int] NULL,
[external_event_config_primary] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[event_owner_id] [bigint] NULL,
[event_owner_name] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[update_datetime] [datetime2] NULL,
[context_id] [bigint] NULL,
[tix_event_id] [bigint] NULL,
[tix_eventzone_id] [bigint] NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL,
[ETL_Sync_UpdatedDate] [datetime] NULL
)
GO
