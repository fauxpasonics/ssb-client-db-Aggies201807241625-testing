CREATE TABLE [ods].[VTXtixsysseatgrouptypes]
(
[ETL_ID] [int] NOT NULL IDENTITY(1, 1),
[ETL_CreatedDate] [datetime] NOT NULL,
[ETL_UpdatedDate] [datetime] NULL,
[ETL_IsDeleted] [bit] NULL,
[ETL_DeletedDate] [datetime] NULL,
[ETL_DeltaHashKey] [binary] (32) NULL,
[ETL_SourceFileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsysseatgrouptypecode] [smallint] NULL,
[tixsysseatgrouptypedesc] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsysseatgrouptypedisplayordr] [smallint] NULL,
[tixsysseatgrptypenextleveldown] [nvarchar] (48) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsysseatgrouptypeshortdesc] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsysseatgrouptypeprocessctrl] [nvarchar] (192) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsysseatgrouptypeinvntryctrl] [smallint] NULL,
[tixsysseatgrouptypefieldscode] [smallint] NULL,
[tixsysvalidtopseatgrouptype] [smallint] NULL
)
GO
ALTER TABLE [ods].[VTXtixsysseatgrouptypes] ADD CONSTRAINT [PK__VTXtixsy__7EF6BFCD8A3CA06E] PRIMARY KEY CLUSTERED  ([ETL_ID])
GO
