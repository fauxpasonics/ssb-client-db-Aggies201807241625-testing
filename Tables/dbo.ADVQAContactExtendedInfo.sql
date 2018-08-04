CREATE TABLE [dbo].[ADVQAContactExtendedInfo]
(
[contactid] [int] NOT NULL,
[ADNumber] [int] NULL,
[AlumniInfo] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContactType] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PrefClassYear] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SpousePrefClassYear] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdvanceID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdvancePrefName] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdvanceSpouseName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdvanceEmail] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreateDate] [date] NULL,
[UpdateDate] [date] NULL,
[Gender] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PreferredSchool] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SpouseAdvanceID] [int] NULL,
[AdvanceLifetimegiving] [money] NULL,
[AdvanceOrgName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
CREATE NONCLUSTERED INDEX [nci_wi_ADVQAContactExtendedInfo_6D90199BEC0F1C1373548F94D3399030] ON [dbo].[ADVQAContactExtendedInfo] ([contactid]) INCLUDE ([PrefClassYear], [SpousePrefClassYear])
GO
