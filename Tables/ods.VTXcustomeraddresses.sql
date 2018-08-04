CREATE TABLE [ods].[VTXcustomeraddresses]
(
[ETL_ID] [int] NOT NULL IDENTITY(1, 1),
[ETL_CreatedDate] [datetime] NOT NULL,
[ETL_UpdatedDate] [datetime] NULL,
[ETL_IsDeleted] [bit] NULL,
[ETL_DeletedDate] [datetime] NULL,
[ETL_DeltaHashKey] [binary] (32) NULL,
[ETL_SourceFileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[addressid] [numeric] (38, 10) NULL,
[shipto] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[description] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address1] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address2] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[city] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[state] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zip] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[country] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customerid] [numeric] (38, 10) NULL,
[active] [numeric] (38, 10) NULL
)
GO
ALTER TABLE [ods].[VTXcustomeraddresses] ADD CONSTRAINT [PK__VTXcusto__7EF6BFCDB2447A10] PRIMARY KEY CLUSTERED  ([ETL_ID])
GO
CREATE NONCLUSTERED INDEX [IDX_VTXcustomeraddresses_addressid_description] ON [ods].[VTXcustomeraddresses] ([addressid], [description])
GO
CREATE NONCLUSTERED INDEX [IDX_VTXcustomeraddresses_description] ON [ods].[VTXcustomeraddresses] ([description])
GO
