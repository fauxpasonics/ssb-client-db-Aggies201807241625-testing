CREATE TABLE [amy].[zz_pacparking_04102018]
(
[donornumber] [nvarchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pacevent] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[paclevel] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tseatsection] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tseatrow] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartSeqNo] [int] NULL,
[EndSeqNo] [int] NULL,
[qty] [int] NULL,
[Pricelevel] [int] NOT NULL,
[PacPriceType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[price] [numeric] (10, 2) NULL,
[fee] [int] NOT NULL,
[pacseasoncode] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pacfacilitycode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[orderdate] [int] NULL,
[specialhandling] [nvarchar] (818) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[markcode] [int] NULL,
[comments] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DispositionCode] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billplancode] [int] NULL,
[liveeventcode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[liveseasoncode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rn] [bigint] NOT NULL,
[ordergroup] [numeric] (10, 0) NULL
)
GO
