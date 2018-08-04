CREATE TABLE [ods].[VTXtixeventzoneseatbarcodes]
(
[ETL_ID] [int] NOT NULL IDENTITY(1, 1),
[ETL_CreatedDate] [datetime] NOT NULL,
[ETL_UpdatedDate] [datetime] NULL,
[ETL_IsDeleted] [bit] NULL,
[ETL_DeletedDate] [datetime] NULL,
[ETL_DeltaHashKey] [binary] (32) NULL,
[ETL_SourceFileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatbarcodeid] [numeric] (10, 0) NULL,
[tixeventid] [numeric] (10, 0) NULL,
[tixeventzoneid] [smallint] NULL,
[tixseatgroupid] [int] NULL,
[tixseatid] [numeric] (10, 0) NULL,
[barcode] [nvarchar] (96) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[scandatetime] [datetime2] (6) NULL,
[scanlocation] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[clustercode] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gatenumber] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[validationresponse] [smallint] NULL,
[initdate] [datetime2] (6) NULL
)
GO
ALTER TABLE [ods].[VTXtixeventzoneseatbarcodes] ADD CONSTRAINT [PK__VTXtixev__7EF6BFCD93B2AE1D] PRIMARY KEY CLUSTERED  ([ETL_ID])
GO
CREATE NONCLUSTERED INDEX [IDX_VTXtixeventzoneseatbarcodes_bc] ON [ods].[VTXtixeventzoneseatbarcodes] ([barcode])
GO
CREATE UNIQUE NONCLUSTERED INDEX [IDX_VTXtixeventzoneseatbarcodes] ON [ods].[VTXtixeventzoneseatbarcodes] ([tixseatbarcodeid])
GO
