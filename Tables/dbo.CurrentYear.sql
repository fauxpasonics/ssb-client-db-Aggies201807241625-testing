CREATE TABLE [dbo].[CurrentYear]
(
[CurrentYear] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CurrentSeason] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TicketOfficeEmail] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF4] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UDF5] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstBillingMonth] [int] NULL,
[SchoolID] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailProgram] [int] NOT NULL,
[PriorityPointCalc] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DonorNet] [bit] NOT NULL,
[DonorNetYear] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DonorNetSeason] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PacXfer] [bit] NULL,
[AddressChangeEmail] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
ALTER TABLE [dbo].[CurrentYear] ADD CONSTRAINT [PK_CurrentYear_96bf722c-92d3-4f1b-a3fc-48e55f0caad3] PRIMARY KEY CLUSTERED  ([CurrentYear])
GO
