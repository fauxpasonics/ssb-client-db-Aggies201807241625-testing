CREATE TABLE [ods].[VTXtixsysoutlettypes]
(
[ETL_ID] [int] NOT NULL IDENTITY(1, 1),
[ETL_CreatedDate] [datetime] NOT NULL,
[ETL_UpdatedDate] [datetime] NULL,
[ETL_IsDeleted] [bit] NULL,
[ETL_DeletedDate] [datetime] NULL,
[ETL_DeltaHashKey] [binary] (32) NULL,
[ETL_SourceFileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsysoutlettypedesc] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsysoutlettypeinitdate] [datetime2] (6) NULL,
[tixsysoutlettypelastupdwhen] [datetime2] (6) NULL,
[tixsysoutlettypelastupdwho] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsysoutlettype] [smallint] NULL,
[outlettyperegionrprtspecifier] [smallint] NULL,
[tixsysoutlettypedisporder] [smallint] NULL
)
GO
ALTER TABLE [ods].[VTXtixsysoutlettypes] ADD CONSTRAINT [PK__VTXtixsy__7EF6BFCD6649C659] PRIMARY KEY CLUSTERED  ([ETL_ID])
GO
