CREATE TABLE [amy].[zzF18IndividualSeats_0226]
(
[seatareacode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SeatAreaName] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Season] [nvarchar] (48) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tseatsection] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tseatrow] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tseatseat] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SeatType] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Obstructed] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DonorNumber] [nvarchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsyspricecodedesc] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsysseatstatusdesc] [nvarchar] (78) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsyspriceleveldesc] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ETL_DeletedDate] [datetime] NULL,
[tixseatshippingoption] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ordergroupdate] [datetime2] (6) NULL,
[ordergrouppaymentmode] [smallint] NULL,
[ordergroupshippingdestmode] [smallint] NULL,
[ordergroupshippingzone] [int] NULL,
[tixseatpriceafterdiscounts] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ordergroup] [numeric] (10, 0) NULL,
[comments] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
