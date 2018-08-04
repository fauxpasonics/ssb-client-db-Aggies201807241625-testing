CREATE TABLE [ods].[VTXtixsyspricecodetypes]
(
[ETL_ID] [int] NOT NULL IDENTITY(1, 1),
[ETL_CreatedDate] [datetime] NOT NULL,
[ETL_UpdatedDate] [datetime] NULL,
[ETL_IsDeleted] [bit] NULL,
[ETL_DeletedDate] [datetime] NULL,
[ETL_DeltaHashKey] [binary] (32) NULL,
[ETL_SourceFileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsyspricecodetype] [numeric] (10, 0) NULL,
[tixsyspricecodetypedesc] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsyspricecodetypeinitdate] [datetime2] (6) NULL,
[tixsyspricecodetypelastupdwhen] [datetime2] (6) NULL,
[tixsyspricecodetypelastupdwho] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsyspricecodetypedispord] [smallint] NULL
)
GO
ALTER TABLE [ods].[VTXtixsyspricecodetypes] ADD CONSTRAINT [PK__VTXtixsy__7EF6BFCDCF108B1B] PRIMARY KEY CLUSTERED  ([ETL_ID])
GO
