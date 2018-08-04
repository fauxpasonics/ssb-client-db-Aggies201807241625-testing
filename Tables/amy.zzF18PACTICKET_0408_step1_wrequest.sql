CREATE TABLE [amy].[zzF18PACTICKET_0408_step1_wrequest]
(
[Season] [nvarchar] (48) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tseatsection] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tseatrow] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tseatseat] [int] NULL,
[PacLevel] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PacFacilityCode] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PacEvent] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PacSeasonCode] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PacLiveSeasonCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PACConvertedItem] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DonorNumber] [nvarchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsyspricecodedesc] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsysseatstatusdesc] [nvarchar] (78) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsyspriceleveldesc] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ETL_DeletedDate] [int] NULL,
[tixseatshippingoption] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ordergroupdate] [datetime2] (6) NULL,
[ordergrouppaymentmode] [smallint] NULL,
[DispositionCode] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ordergroupshippingdestmode] [smallint] NULL,
[ordergroupshippingzone] [int] NULL,
[tixseatpriceafterdiscounts] [decimal] (28, 10) NULL,
[ordergroup] [numeric] (10, 0) NULL,
[comments] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderaddress] [numeric] (10, 0) NULL,
[primaddress] [int] NULL,
[SpecialHandling] [nvarchar] (818) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[primary_address] [nvarchar] (818) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PacPriceType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fee] [numeric] (3, 1) NULL,
[tixseatid] [int] NULL
)
GO
