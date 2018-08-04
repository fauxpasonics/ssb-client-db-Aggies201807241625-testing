CREATE TABLE [amy].[fstamuevents]
(
[event_id] [numeric] (18, 0) NULL,
[name] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[name_short] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[opens_datetime] [datetime] NULL,
[start_datetime] [datetime] NULL,
[offer_ceiling_amount] [money] NULL,
[offer_ceiling_percent] [decimal] (18, 0) NULL,
[offer_floor_amount] [money] NULL,
[offer_floor_percent] [decimal] (18, 0) NULL,
[external_event_config_primary] [numeric] (18, 0) NULL,
[event_owner_id] [numeric] (18, 0) NULL,
[event_owner_name] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[update_datetime] [datetime] NULL,
[context_id] [numeric] (18, 0) NULL,
[tix_event_id] [numeric] (18, 0) NULL,
[tix_eventzone_id] [numeric] (18, 0) NULL
)
GO
