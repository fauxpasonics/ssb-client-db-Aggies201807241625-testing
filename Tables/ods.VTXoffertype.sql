CREATE TABLE [ods].[VTXoffertype]
(
[ETL_ID] [int] NOT NULL IDENTITY(1, 1),
[ETL_CreatedDate] [datetime] NOT NULL,
[ETL_UpdatedDate] [datetime] NULL,
[ETL_IsDeleted] [bit] NULL,
[ETL_DeletedDate] [datetime] NULL,
[ETL_DeltaHashKey] [binary] (32) NULL,
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
ALTER TABLE [ods].[VTXoffertype] ADD CONSTRAINT [PK__VTXoffer__7EF6BFCDE18B2523] PRIMARY KEY CLUSTERED  ([ETL_ID])
GO
