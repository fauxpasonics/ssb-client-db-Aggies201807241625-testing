CREATE TABLE [amy].[zz_F15Seats]
(
[Season] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Game] [nvarchar] (48) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tseatsection] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tseatrow] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tseatseat] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Used] [int] NOT NULL,
[RegularScan] [datetime] NULL,
[FlashSeatScan] [datetime2] NULL
)
GO
