CREATE TABLE [dbo].[DimSeat]
(
[DimSeatId] [int] NOT NULL,
[DimArenaId] [int] NOT NULL,
[ManifestId] [smallint] NULL,
[SectionName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SectionDesc] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SectionSort] [int] NULL,
[RowName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RowSort] [int] NULL,
[Seat] [int] NULL,
[DefaultClass] [int] NULL,
[DefaultPriceCode] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSCreatedBy] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSUpdatedBy] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSCreatedDate] [smalldatetime] NULL,
[SSUpdatedDate] [smalldatetime] NULL,
[SSID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSID_manifest_id] [int] NULL,
[SSID_section_id] [int] NULL,
[SSID_row_id] [int] NULL,
[SSID_seat] [int] NULL,
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
ALTER TABLE [dbo].[DimSeat] ADD CONSTRAINT [PK_DimSeat] PRIMARY KEY CLUSTERED  ([DimSeatId])
GO
