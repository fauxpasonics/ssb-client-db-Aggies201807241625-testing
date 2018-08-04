CREATE TABLE [ods].[VTXtixeventzonepricelevels]
(
[ETL_ID] [int] NOT NULL IDENTITY(1, 1),
[ETL_CreatedDate] [datetime] NOT NULL,
[ETL_UpdatedDate] [datetime] NULL,
[ETL_IsDeleted] [bit] NULL,
[ETL_DeletedDate] [datetime] NULL,
[ETL_DeltaHashKey] [binary] (32) NULL,
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
ALTER TABLE [ods].[VTXtixeventzonepricelevels] ADD CONSTRAINT [PK__VTXtixev__7EF6BFCDF762C1D2] PRIMARY KEY CLUSTERED  ([ETL_ID])
GO
