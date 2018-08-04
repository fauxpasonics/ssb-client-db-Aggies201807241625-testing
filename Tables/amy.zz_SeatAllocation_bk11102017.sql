CREATE TABLE [amy].[zz_SeatAllocation_bk11102017]
(
[SeatAllocationID] [int] NOT NULL IDENTITY(1, 1),
[ProgramID] [int] NULL,
[ProgramCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramName] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramTypeName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SeatAreaID] [int] NOT NULL,
[SeatAreaName] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SeatAllotmentID] [int] NOT NULL,
[CreateDate] [datetime] NULL,
[CreateUser] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdateDate] [datetime] NULL,
[UpdateUser] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramTypeCode] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Amount] [money] NULL,
[primaryallocation] [bit] NULL,
[sporttype] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inactive_ind] [bit] NULL,
[primarystartyear] [int] NULL,
[primaryendyear] [int] NULL
)
GO
