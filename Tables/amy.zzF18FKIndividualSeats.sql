CREATE TABLE [amy].[zzF18FKIndividualSeats]
(
[Season] [nvarchar] (48) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tseatsection] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tseatrow] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tseatseat] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SeatType] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Obstructed] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MaskedDonorNumber] [int] NULL,
[tixsyspricecodedesc] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsysseatstatusdesc] [nvarchar] (78) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsyspriceleveldesc] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ETL_DeletedDate] [datetime] NULL
)
GO
