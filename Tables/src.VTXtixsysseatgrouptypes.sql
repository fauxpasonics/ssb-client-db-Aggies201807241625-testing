CREATE TABLE [src].[VTXtixsysseatgrouptypes]
(
[ETL_ID] [int] NOT NULL,
[ETL_CreatedDate] [datetime] NOT NULL,
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
