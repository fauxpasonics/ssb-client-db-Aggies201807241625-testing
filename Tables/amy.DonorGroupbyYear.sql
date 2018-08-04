CREATE TABLE [amy].[DonorGroupbyYear]
(
[DonorGroupbyYearID] [int] NOT NULL IDENTITY(1, 1),
[DonorGroupSummaryID] [int] NULL,
[ContactId] [int] NOT NULL,
[GroupID] [int] NOT NULL,
[MemberYear] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProgramId] [int] NULL,
[CategoryId] [int] NULL,
[Lifetime] [bit] NULL,
[TerritoryCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EstimatedYear] [bit] NULL,
[Notes] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ComplimentaryMembership] [bit] NULL,
[CreateDate] [date] NULL,
[CreateUser] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdateDate] [date] NULL,
[UpdateUser] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DonorCount] [int] NULL,
[ComplimentaryMembershipReason] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[adnumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
CREATE NONCLUSTERED INDEX [DonorGroupbyYear_ind01] ON [amy].[DonorGroupbyYear] ([adnumber], [GroupID], [MemberYear])
GO
CREATE NONCLUSTERED INDEX [DonorGroupbyYear_ind02] ON [amy].[DonorGroupbyYear] ([GroupID], [MemberYear])
GO
