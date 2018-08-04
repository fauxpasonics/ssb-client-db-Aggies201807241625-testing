CREATE TABLE [amy].[zz_pacticket_B16W06032018_fix_wrequests]
(
[donornumber] [nvarchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pacevent] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[paclevel] [int] NULL,
[tseatsection] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tseatrow] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartSeqNo] [int] NULL,
[EndSeqNo] [int] NULL,
[qty] [int] NULL,
[Pricelevel] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PacPriceType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[price] [numeric] (10, 2) NULL,
[fee] [numeric] (4, 2) NULL,
[pacseasoncode] [nvarchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pacfacilitycode] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderdate] [int] NULL,
[specialhandling] [nvarchar] (818) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[markcode] [int] NULL,
[comments] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DispositionCode] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billplancode] [int] NULL,
[liveeventcode] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[liveseasoncode] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rn] [bigint] NOT NULL,
[ordergroup] [numeric] (10, 0) NULL
)
GO
