CREATE TABLE [dbo].[ADVDonorPayUsers]
(
[UserID] [int] NOT NULL,
[Username] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PasswordHash] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ADNumber] [int] NULL,
[ContactID] [int] NULL,
[Email] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ConfirmSent] [datetime] NOT NULL,
[Confirmed] [bit] NOT NULL,
[NewMember] [bit] NOT NULL,
[NewMemberID] [int] NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
