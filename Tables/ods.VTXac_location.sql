CREATE TABLE [ods].[VTXac_location]
(
[ETL_ID] [int] NOT NULL IDENTITY(1, 1),
[ETL_CreatedDate] [datetime] NOT NULL,
[ETL_UpdatedDate] [datetime] NULL,
[ETL_IsDeleted] [bit] NULL,
[ETL_DeletedDate] [datetime] NULL,
[ETL_DeltaHashKey] [binary] (32) NULL,
[ETL_SourceFileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[locationid] [int] NULL,
[description] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[location] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[server] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[active] [smallint] NULL,
[lastupdated] [datetime2] (6) NULL,
[current_status] [smallint] NULL,
[suite_lock_enabled] [smallint] NULL,
[remotepollenabled] [numeric] (10, 0) NULL
)
GO
ALTER TABLE [ods].[VTXac_location] ADD CONSTRAINT [PK__VTXac_lo__7EF6BFCD882564E8] PRIMARY KEY CLUSTERED  ([ETL_ID])
GO
