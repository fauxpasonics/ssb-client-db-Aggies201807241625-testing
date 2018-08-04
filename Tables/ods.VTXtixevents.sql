CREATE TABLE [ods].[VTXtixevents]
(
[ETL_ID] [int] NOT NULL IDENTITY(1, 1),
[ETL_CreatedDate] [datetime] NOT NULL,
[ETL_UpdatedDate] [datetime] NULL,
[ETL_IsDeleted] [bit] NULL,
[ETL_DeletedDate] [datetime] NULL,
[ETL_DeltaHashKey] [binary] (32) NULL,
[ETL_SourceFileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixeventid] [numeric] (10, 0) NULL,
[tixeventtitleshort] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixeventtitlelong] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixeventonsale] [datetime2] (6) NULL,
[tixeventstartdate] [datetime2] (6) NULL,
[tixeventenddate] [datetime2] (6) NULL,
[tixeventgatesopen] [datetime2] (6) NULL,
[tixeventtourid] [int] NULL,
[tixeventlookupid] [nvarchar] (48) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixeventinitdate] [datetime2] (6) NULL,
[tixeventlastupdwhen] [datetime2] (6) NULL,
[tixeventlastupdatewho] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixeventtype] [smallint] NULL,
[tixeventemailnotifydate] [datetime2] (6) NULL,
[tixeventcategoryid] [numeric] (38, 10) NULL,
[establishmenttype] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixrenewalid] [numeric] (38, 10) NULL,
[tixeventcurrentuntil] [datetime2] (6) NULL,
[display_in_reports] [smallint] NULL,
[tixeventdisplaydate] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixeventimagepath] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixeventsoundfilepath] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixeventvisible] [smallint] NULL,
[eticketschedule] [datetime2] (6) NULL,
[allowcontinueshopping] [smallint] NULL,
[venueestablishmenttype] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[venueestablishmentkey] [numeric] (10, 0) NULL,
[ac_exportevent] [smallint] NULL,
[client_id] [numeric] (10, 0) NULL,
[flashseats_schedule] [datetime2] (6) NULL,
[tixeventversion] [numeric] (18, 0) NULL,
[tixeventkeywords] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixeventinternalinformation] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[web_tracking_profile_id] [numeric] (10, 0) NULL,
[default_offer_id] [numeric] (18, 0) NULL,
[visible_to_web] [smallint] NULL,
[image_id] [numeric] (18, 0) NULL,
[flasheventid] [numeric] (38, 10) NULL
)
GO
ALTER TABLE [ods].[VTXtixevents] ADD CONSTRAINT [PK__VTXtixev__7EF6BFCD88F1A834] PRIMARY KEY CLUSTERED  ([ETL_ID])
GO
CREATE NONCLUSTERED INDEX [IDX_VTXtixevents_tixeventid] ON [ods].[VTXtixevents] ([tixeventid])
GO
CREATE NONCLUSTERED INDEX [idx_tixevents_tixeventlookupid] ON [ods].[VTXtixevents] ([tixeventlookupid])
GO
