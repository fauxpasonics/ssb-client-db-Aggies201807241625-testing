CREATE TABLE [src].[VTXtixsyspricelevels]
(
[ETL_ID] [int] NOT NULL,
[ETL_CreatedDate] [datetime] NOT NULL,
[ETL_SourceFileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsyspricelevelcode] [numeric] (10, 0) NULL,
[tixsyspriceleveldesc] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsyspricelevelinitdate] [datetime2] (6) NULL,
[tixsyspricelevellastupdwhen] [datetime2] (6) NULL,
[tixsyspricelevellastupdatewho] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsyspricelevelcolors] [nvarchar] (192) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsyspriceleveltype] [smallint] NULL,
[tixsyspricelevelmodatnextlevel] [smallint] NULL,
[tissyspriceleveldispord] [smallint] NULL,
[tixsyshiddenstatus] [smallint] NULL
)
GO
