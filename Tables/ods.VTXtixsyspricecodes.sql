CREATE TABLE [ods].[VTXtixsyspricecodes]
(
[ETL_ID] [int] NOT NULL IDENTITY(1, 1),
[ETL_CreatedDate] [datetime] NOT NULL,
[ETL_UpdatedDate] [datetime] NULL,
[ETL_IsDeleted] [bit] NULL,
[ETL_DeletedDate] [datetime] NULL,
[ETL_DeltaHashKey] [binary] (32) NULL,
[ETL_SourceFileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsyspricecodecode] [numeric] (10, 0) NULL,
[tixsyspricecodedesc] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsyspricecodeinitdate] [datetime2] (6) NULL,
[tixsyspricecodelastupdwhen] [datetime2] (6) NULL,
[tixsyspricecodelastupdatewho] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsyspricecodecolors] [nvarchar] (192) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsyspricecodetype] [numeric] (10, 0) NULL,
[tixsyspricecodemodatnextlevel] [smallint] NULL,
[tixsyspricecodetextdesc] [nvarchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsyspricecodedispord] [smallint] NULL,
[tixsyspricecodesalesmodes] [smallint] NULL,
[tixsyscompseatstatuscode] [smallint] NULL,
[tixsyspricecodealtprintdesc] [nvarchar] (90) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[printable] [smallint] NULL,
[is_comp] [smallint] NULL,
[tixsyspricecodepaypri] [int] NULL,
[tixsyspricecodepricingmode] [int] NULL,
[restrict_transfer] [smallint] NULL,
[restrict_resale] [smallint] NULL,
[waive_first_seller_fee] [smallint] NULL,
[stadis_active] [smallint] NULL,
[hidden_status] [smallint] NULL,
[restrict_transfer_to_fs] [smallint] NULL
)
GO
ALTER TABLE [ods].[VTXtixsyspricecodes] ADD CONSTRAINT [PK__VTXtixsy__7EF6BFCD19399983] PRIMARY KEY CLUSTERED  ([ETL_ID])
GO
CREATE NONCLUSTERED INDEX [IDX_VTXtixsyspricecodes_tixsyspricecodecode] ON [ods].[VTXtixsyspricecodes] ([tixsyspricecodecode])
GO
ALTER INDEX [IDX_VTXtixsyspricecodes_tixsyspricecodecode] ON [ods].[VTXtixsyspricecodes] DISABLE
GO
