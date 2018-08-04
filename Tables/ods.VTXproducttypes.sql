CREATE TABLE [ods].[VTXproducttypes]
(
[ETL_ID] [int] NOT NULL IDENTITY(1, 1),
[ETL_CreatedDate] [datetime] NOT NULL,
[ETL_UpdatedDate] [datetime] NULL,
[ETL_IsDeleted] [bit] NULL,
[ETL_DeletedDate] [datetime] NULL,
[ETL_DeltaHashKey] [binary] (32) NULL,
[ETL_SourceFileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[producttype] [int] NULL,
[producttypedescription] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[producttypefullfillmentprocess] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[producttypeprocessoffline] [smallint] NULL,
[producttypeinitdate] [datetime2] (6) NULL,
[producttypelastupdatewhen] [datetime2] (6) NULL,
[producttypelastupdatewho] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[producttypedisplayorder] [int] NULL,
[producttyperecordextensions] [nvarchar] (48) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[producttypeinventorymethod] [smallint] NULL
)
GO
ALTER TABLE [ods].[VTXproducttypes] ADD CONSTRAINT [PK__VTXprodu__7EF6BFCDCF92D010] PRIMARY KEY CLUSTERED  ([ETL_ID])
GO
