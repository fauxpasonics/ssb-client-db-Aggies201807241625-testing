CREATE TABLE [src].[VTXcustomeraddresses]
(
[ETL_ID] [int] NOT NULL,
[ETL_CreatedDate] [datetime] NOT NULL,
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
CREATE NONCLUSTERED INDEX [IX_customerid] ON [src].[VTXcustomeraddresses] ([customerid])
GO
ALTER INDEX [IX_customerid] ON [src].[VTXcustomeraddresses] DISABLE
GO
