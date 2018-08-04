CREATE TABLE [ods].[VTXtixeventzonecomponentchart]
(
[ETL_ID] [int] NOT NULL IDENTITY(1, 1),
[ETL_CreatedDate] [datetime] NOT NULL,
[ETL_UpdatedDate] [datetime] NULL,
[ETL_IsDeleted] [bit] NULL,
[ETL_DeletedDate] [datetime] NULL,
[ETL_DeltaHashKey] [binary] (32) NULL,
[ETL_SourceFileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixeventid] [numeric] (10, 0) NULL,
[tixeventzoneid] [int] NULL,
[tixevtznpricelevelcode] [numeric] (10, 0) NULL,
[tixevtznpricecodecode] [numeric] (10, 0) NULL,
[component1price] [numeric] (18, 4) NULL,
[component2price] [numeric] (18, 4) NULL,
[component3price] [numeric] (18, 4) NULL,
[component4price] [numeric] (18, 4) NULL,
[component5price] [numeric] (18, 4) NULL
)
GO
ALTER TABLE [ods].[VTXtixeventzonecomponentchart] ADD CONSTRAINT [PK__VTXtixev__7EF6BFCD21C9BEB4] PRIMARY KEY CLUSTERED  ([ETL_ID])
GO
