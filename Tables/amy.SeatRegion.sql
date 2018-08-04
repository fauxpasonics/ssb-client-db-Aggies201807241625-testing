CREATE TABLE [amy].[SeatRegion]
(
[SeatRegionID] [int] NOT NULL IDENTITY(1, 1),
[SeatRegionName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateUpdated] [datetime] NULL,
[Cap_Amount] [money] NULL,
[Annual_Amount] [money] NULL,
[Lettermen_Cap_Credit] [money] NULL,
[Lettermen_Annual_Credit] [money] NULL,
[Faculty_Cap_Credit] [money] NULL,
[Faculty_Annual_Credit] [money] NULL,
[Lettermen_Credit_Seat_Limit] [int] NULL,
[Faculty_Credit_Seat_Limit] [int] NULL,
[Endowed_Annual_Credit] [int] NULL,
[Seatsincluded] [bit] NULL,
[FacultyAD_Cap_Credit] [money] NULL,
[FacultyAD_Annual_Credit] [money] NULL,
[sporttype] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[locationid] [int] NULL,
[sportid] [int] NULL,
[sectiongroup] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
ALTER TABLE [amy].[SeatRegion] ADD CONSTRAINT [PK__SeatRegi__5F4706D8E1EBB8CC] PRIMARY KEY CLUSTERED  ([SeatRegionID])
GO
CREATE NONCLUSTERED INDEX [index_seatregion_sportid] ON [amy].[SeatRegion] ([sportid])
GO
CREATE NONCLUSTERED INDEX [idx_Nonclustered_SeatRegion_Sporttype] ON [amy].[SeatRegion] ([sporttype])
GO
ALTER TABLE [amy].[SeatRegion] WITH NOCHECK ADD CONSTRAINT [FK__SeatRegio__sport__03E676AB] FOREIGN KEY ([sportid]) REFERENCES [amy].[Sport] ([SportID])
GO
ALTER TABLE [amy].[SeatRegion] NOCHECK CONSTRAINT [FK__SeatRegio__sport__03E676AB]
GO
