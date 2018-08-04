CREATE TABLE [src].[VTXtixeventzonepricelevels]
(
[ETL_ID] [int] NOT NULL,
[ETL_CreatedDate] [datetime] NOT NULL,
[ETL_SourceFileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixeventid] [numeric] (10, 0) NULL,
[tixeventzoneid] [smallint] NULL,
[tixevtznpricelevelcode] [numeric] (10, 0) NULL,
[tixevtznpriceleveldesc] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixevtznpricelevelinitdate] [datetime2] (6) NULL,
[tixevtznpricelevellastupdwhen] [datetime2] (6) NULL,
[tixevtznpricelevellastupdwho] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixevtznpricelevelcolors] [nvarchar] (192) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixevtznpriceleveltype] [smallint] NULL,
[tixevtznpricelevelmodatnextlvl] [smallint] NULL,
[tixevtznpriceleveldispord] [smallint] NULL,
[tixevtznpricelevelprintdesc] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
