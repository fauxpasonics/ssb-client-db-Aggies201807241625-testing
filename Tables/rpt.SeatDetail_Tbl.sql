CREATE TABLE [rpt].[SeatDetail_Tbl]
(
[accountnumber] [nvarchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[categoryname] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixeventlookupid] [nvarchar] (48) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixeventtitleshort] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixeventid] [numeric] (10, 0) NULL,
[year] [int] NULL,
[seatpricecode] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[seatsection] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[seatrow] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[seatseat] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixseatid] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsyspricecode] [numeric] (10, 0) NULL,
[paid] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sent] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
)
GO
