CREATE TABLE [dbo].[DimEventHeader]
(
[DimEventHeaderId] [int] NOT NULL,
[DimArenaId] [int] NOT NULL,
[DimSeasonHeaderId] [int] NOT NULL,
[OpponentDimTeamId] [int] NOT NULL,
[DimGameInfoId] [int] NOT NULL,
[EventName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventDesc] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventHierarchyL1] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventHierarchyL2] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventHierarchyL3] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventHierarchyL4] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventHierarchyL5] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventDate] [date] NULL,
[EventTime] [time] NULL,
[EventDateTime] [smalldatetime] NULL,
[EventOpenTime] [smalldatetime] NULL,
[EventFinishTime] [smalldatetime] NULL,
[EventSeasonNumber] [int] NULL,
[HomeGameNumber] [int] NULL,
[GameNumber] [int] NULL,
[IsSportingEvent] [bit] NULL,
[CreatedBy] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdatedBy] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedDate] [smalldatetime] NOT NULL,
[UpdatedDate] [smalldatetime] NOT NULL,
[IsDeleted] [bit] NOT NULL,
[DeleteDate] [smalldatetime] NULL
)
GO
ALTER TABLE [dbo].[DimEventHeader] ADD CONSTRAINT [PK_DimEventHeader] PRIMARY KEY CLUSTERED  ([DimEventHeaderId])
GO
