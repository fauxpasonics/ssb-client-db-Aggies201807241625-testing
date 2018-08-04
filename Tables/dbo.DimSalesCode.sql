CREATE TABLE [dbo].[DimSalesCode]
(
[DimSalesCodeId] [int] NOT NULL,
[SalesCode] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SalesCodeName] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SalesCodeDesc] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SalesCodeClass] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsHost] [bit] NULL,
[SalesCodeStartDate] [date] NULL,
[SalesCodeEndDate] [date] NULL,
[SalesCodeStatus] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSCreatedBy] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSUpdatedBy] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSCreatedDate] [smalldatetime] NULL,
[SSUpdatedDate] [smalldatetime] NULL,
[SSID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSID_sell_location_id] [int] NULL,
[SourceSystem] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeltaHashKey] [binary] (32) NULL,
[CreatedBy] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdatedBy] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedDate] [smalldatetime] NOT NULL,
[UpdatedDate] [smalldatetime] NOT NULL,
[IsDeleted] [bit] NOT NULL,
[DeleteDate] [smalldatetime] NULL
)
GO
ALTER TABLE [dbo].[DimSalesCode] ADD CONSTRAINT [PK_DimSalesCode] PRIMARY KEY CLUSTERED  ([DimSalesCodeId])
GO
