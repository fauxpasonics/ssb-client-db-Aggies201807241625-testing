CREATE TABLE [amy].[seatdetail_flat_tmp]
(
[accountnumber] [nvarchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[categoryname] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixeventlookupid] [nvarchar] (48) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixeventtitleshort] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixeventid] [numeric] (10, 0) NULL,
[qty] [int] NULL,
[seatblock] [nvarchar] (755) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[year] [int] NULL,
[seatpricecode] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsyspricecode] [numeric] (10, 0) NULL,
[seatsection] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[seatrow] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[seatseat] [nvarchar] (302) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[paid] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sent] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[updatedate] [datetime] NOT NULL
)
GO
