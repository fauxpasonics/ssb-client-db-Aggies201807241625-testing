CREATE TABLE [src].[VTXtixsysoutlettypes]
(
[ETL_ID] [int] NOT NULL,
[ETL_CreatedDate] [datetime] NOT NULL,
[ETL_SourceFileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsysoutlettypedesc] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsysoutlettypeinitdate] [datetime2] (6) NULL,
[tixsysoutlettypelastupdwhen] [datetime2] (6) NULL,
[tixsysoutlettypelastupdwho] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsysoutlettype] [smallint] NULL,
[outlettyperegionrprtspecifier] [smallint] NULL,
[tixsysoutlettypedisporder] [smallint] NULL
)
GO
