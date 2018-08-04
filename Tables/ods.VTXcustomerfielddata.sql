CREATE TABLE [ods].[VTXcustomerfielddata]
(
[ETL_ID] [int] NOT NULL IDENTITY(1, 1),
[ETL_CreatedDate] [datetime] NOT NULL,
[ETL_UpdatedDate] [datetime] NULL,
[ETL_IsDeleted] [bit] NULL,
[ETL_DeletedDate] [datetime] NULL,
[ETL_DeltaHashKey] [binary] (32) NULL,
[ETL_SourceFileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customerid] [numeric] (38, 10) NULL,
[customerfieldid] [numeric] (38, 10) NULL,
[stringvalue] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[datevalue] [datetime2] (6) NULL,
[numericvalue] [numeric] (10, 0) NULL
)
GO
CREATE NONCLUSTERED INDEX [IDX_customerfieldid] ON [ods].[VTXcustomerfielddata] ([customerfieldid])
GO
CREATE NONCLUSTERED INDEX [IDX_customerid] ON [ods].[VTXcustomerfielddata] ([customerid])
GO
