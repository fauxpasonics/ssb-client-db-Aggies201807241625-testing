CREATE TABLE [ods].[PAC_DW_AccountUDFTranslations]
(
[UDFnum] [int] NOT NULL,
[UDFDefinitionID] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[DataTypeCode] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
CREATE CLUSTERED COLUMNSTORE INDEX [CCI_ods__PAC_DW_AccountUDFTranslations] ON [ods].[PAC_DW_AccountUDFTranslations]
GO
