CREATE TABLE [ods].[VTXtixsyspricelevels]
(
[ETL_ID] [int] NOT NULL IDENTITY(1, 1),
[ETL_CreatedDate] [datetime] NOT NULL,
[ETL_UpdatedDate] [datetime] NULL,
[ETL_IsDeleted] [bit] NULL,
[ETL_DeletedDate] [datetime] NULL,
[ETL_DeltaHashKey] [binary] (32) NULL,
[ETL_SourceFileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsyspricelevelcode] [numeric] (10, 0) NULL,
[tixsyspriceleveldesc] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsyspricelevelinitdate] [datetime2] (6) NULL,
[tixsyspricelevellastupdwhen] [datetime2] (6) NULL,
[tixsyspricelevellastupdatewho] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsyspricelevelcolors] [nvarchar] (192) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsyspriceleveltype] [smallint] NULL,
[tixsyspricelevelmodatnextlevel] [smallint] NULL,
[tissyspriceleveldispord] [smallint] NULL,
[tixsyshiddenstatus] [smallint] NULL
)
GO
ALTER TABLE [ods].[VTXtixsyspricelevels] ADD CONSTRAINT [PK__VTXtixsy__7EF6BFCDDFFD42E8] PRIMARY KEY CLUSTERED  ([ETL_ID])
GO
