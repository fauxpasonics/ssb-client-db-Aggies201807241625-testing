CREATE TABLE [amy].[sport_tickets]
(
[Customer Account Num] [nvarchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Customer Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Neighborhood] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Section] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Row] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Seat] [nvarchar] (302) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Price Code] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Quantity] [int] NULL,
[Sport] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Season] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Year] [int] NULL,
[DateUpdated] [datetime] NOT NULL,
[seatblock] [nvarchar] (755) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
