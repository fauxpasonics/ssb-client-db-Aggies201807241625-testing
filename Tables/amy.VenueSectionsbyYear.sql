CREATE TABLE [amy].[VenueSectionsbyYear]
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
[sportid] [int] NULL,
[startyear] [int] NOT NULL,
[endyear] [int] NOT NULL,
[annual_amount_alt] [money] NULL
)
GO
CREATE NONCLUSTERED INDEX [index_venuesectionsbyyear_sportid] ON [amy].[VenueSectionsbyYear] ([sportid])
GO
CREATE NONCLUSTERED INDEX [index_venuesectionsbyyear_sportid_startend] ON [amy].[VenueSectionsbyYear] ([sportid], [startyear], [endyear])
GO
CREATE NONCLUSTERED INDEX [idx_Nonclustered_VenueSectionsbyyear_sporttype_SectionNum_Rows] ON [amy].[VenueSectionsbyYear] ([sporttype], [SectionNum], [Rows])
GO
CREATE NONCLUSTERED INDEX [index_venuesectionsbyyear_sportid_startend_sporttype] ON [amy].[VenueSectionsbyYear] ([sporttype], [SectionNum], [startyear], [endyear])
GO
