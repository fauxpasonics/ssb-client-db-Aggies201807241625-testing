CREATE TABLE [src].[VTXtixsyspricecodetypes]
(
[ETL_ID] [int] NOT NULL,
[ETL_CreatedDate] [datetime] NOT NULL,
[ETL_SourceFileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsyspricecodetype] [numeric] (10, 0) NULL,
[tixsyspricecodetypedesc] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsyspricecodetypeinitdate] [datetime2] (6) NULL,
[tixsyspricecodetypelastupdwhen] [datetime2] (6) NULL,
[tixsyspricecodetypelastupdwho] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsyspricecodetypedispord] [smallint] NULL
)
GO
