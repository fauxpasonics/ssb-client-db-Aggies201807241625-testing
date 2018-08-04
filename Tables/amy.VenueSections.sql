CREATE TABLE [amy].[VenueSections]
(
[venuesectionid] [int] NOT NULL IDENTITY(1, 1),
[locationid] [int] NOT NULL,
[sporttype] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SeatingDescription] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SeatingArea] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SectionNum] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Rows] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SeatAreaID] [int] NULL,
[seatregionid] [int] NULL,
[createdate] [datetime] NOT NULL,
[createuser] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[updatedate] [datetime] NOT NULL,
[updateuser] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sportid] [int] NULL
)
GO
ALTER TABLE [amy].[VenueSections] ADD CONSTRAINT [PK__VenueSec__15EEDB4CAEEE5CB7] PRIMARY KEY CLUSTERED  ([venuesectionid])
GO
CREATE NONCLUSTERED INDEX [index_venuesections_sportid] ON [amy].[VenueSections] ([sportid])
GO
CREATE NONCLUSTERED INDEX [idx_Nonclustered_VenueSections_sporttype_SectionNum_Rows] ON [amy].[VenueSections] ([sporttype], [SectionNum], [Rows])
GO
ALTER TABLE [amy].[VenueSections] WITH NOCHECK ADD CONSTRAINT [FK__VenueSect__SeatA__04DA9AE4] FOREIGN KEY ([SeatAreaID]) REFERENCES [amy].[SeatArea] ([SeatAreaID])
GO
ALTER TABLE [amy].[VenueSections] WITH NOCHECK ADD CONSTRAINT [FK__VenueSect__seatr__06C2E356] FOREIGN KEY ([seatregionid]) REFERENCES [amy].[SeatRegion] ([SeatRegionID])
GO
ALTER TABLE [amy].[VenueSections] WITH NOCHECK ADD CONSTRAINT [FK__VenueSect__sport__05CEBF1D] FOREIGN KEY ([sportid]) REFERENCES [amy].[Sport] ([SportID])
GO
ALTER TABLE [amy].[VenueSections] NOCHECK CONSTRAINT [FK__VenueSect__SeatA__04DA9AE4]
GO
ALTER TABLE [amy].[VenueSections] NOCHECK CONSTRAINT [FK__VenueSect__seatr__06C2E356]
GO
ALTER TABLE [amy].[VenueSections] NOCHECK CONSTRAINT [FK__VenueSect__sport__05CEBF1D]
GO
