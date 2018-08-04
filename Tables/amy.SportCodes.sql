CREATE TABLE [amy].[SportCodes]
(
[SportID] [int] NULL,
[SportType] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SportCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GenderCode] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CurrentSeason_TwoDigit] [smallint] NULL,
[PriorSeason_TwoDigit] [smallint] NULL,
[SeasonTicketEventIDView] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SingleGameEventListView] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
