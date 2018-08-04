CREATE TABLE [ods].[PAC_DW_AddressTranslations]
(
[AddrNum] [int] NOT NULL,
[AddressTypeCode] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_ods__PAC_DW_AddressTranslations] ON [ods].[PAC_DW_AddressTranslations]
GO
