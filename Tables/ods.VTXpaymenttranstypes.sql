CREATE TABLE [ods].[VTXpaymenttranstypes]
(
[ETL_ID] [int] NOT NULL IDENTITY(1, 1),
[ETL_CreatedDate] [datetime] NOT NULL,
[ETL_UpdatedDate] [datetime] NULL,
[ETL_IsDeleted] [bit] NULL,
[ETL_DeletedDate] [datetime] NULL,
[ETL_DeltaHashKey] [binary] (32) NULL,
[ETL_SourceFileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[paymenttranstype] [numeric] (10, 0) NULL,
[paymenttranstypedesc] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[paymenttypeprocessingmethod] [smallint] NULL,
[paymenttypewarnonexchange] [smallint] NULL,
[paymenttypefixedsystemvalue] [smallint] NULL,
[paymenttypeactive] [smallint] NULL,
[displayorder] [numeric] (10, 0) NULL,
[paymenttypevalidationpattern] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[paymenttypecheckpattern] [smallint] NULL
)
GO
ALTER TABLE [ods].[VTXpaymenttranstypes] ADD CONSTRAINT [PK__VTXpayme__7EF6BFCD3099D3E2] PRIMARY KEY CLUSTERED  ([ETL_ID])
GO
