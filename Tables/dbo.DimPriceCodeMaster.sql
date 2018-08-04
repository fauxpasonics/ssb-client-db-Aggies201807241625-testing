CREATE TABLE [dbo].[DimPriceCodeMaster]
(
[DimPriceCodeMasterId] [int] NOT NULL,
[ETL_CreatedBy] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ETL_UpdatedBy] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ETL_CreatedDate] [smalldatetime] NOT NULL,
[ETL_UpdatedDate] [smalldatetime] NOT NULL,
[PriceCode] [nvarchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PC1] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PC2] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PC3] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PC4] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
ALTER TABLE [dbo].[DimPriceCodeMaster] ADD CONSTRAINT [PK_DimPriceCodeMaster] PRIMARY KEY CLUSTERED  ([DimPriceCodeMasterId])
GO
