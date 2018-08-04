CREATE TABLE [dbo].[DimClassTM]
(
[DimClassTMId] [int] NOT NULL,
[ETL_CreatedBy] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ETL_UpdatedBy] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ETL_CreatedDate] [smalldatetime] NULL,
[ETL_UpdatedDate] [smalldatetime] NULL,
[ETL_SSID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ETL_SSID_class_id] [int] NULL,
[ETL_DeltaHashKey] [binary] (32) NULL,
[ClassName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClassCategory] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClassType] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsKill] [bit] NOT NULL,
[DistStatus] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DistName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ETL_SourceSystem] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[upd_user] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[upd_datetime] [smalldatetime] NULL,
[matrix_char] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[color] [int] NULL,
[return_class_id] [int] NULL,
[valid_for_reclass] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dist_ett] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ism_class_id] [int] NULL,
[qualifier_state_names] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[system_class] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[qualifier_template] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unsold_type] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unsold_qual_id] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[attrib_type] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[attrib_code] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
ALTER TABLE [dbo].[DimClassTM] ADD CONSTRAINT [PK_DimClassTM] PRIMARY KEY CLUSTERED  ([DimClassTMId])
GO
