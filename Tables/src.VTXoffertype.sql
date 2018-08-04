CREATE TABLE [src].[VTXoffertype]
(
[ETL_ID] [int] NOT NULL,
[ETL_CreatedDate] [datetime] NOT NULL,
[ETL_SourceFileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[offertypeid] [numeric] (20, 0) NULL,
[description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[typeclass] [numeric] (10, 0) NULL,
[eventoutletid] [numeric] (10, 0) NULL,
[packageoutletid] [numeric] (10, 0) NULL,
[nofeesoutletid] [numeric] (10, 0) NULL,
[aetypeids] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
