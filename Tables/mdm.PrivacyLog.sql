CREATE TABLE [mdm].[PrivacyLog]
(
[PrivacyLogID] [int] NOT NULL IDENTITY(1, 1),
[ClientName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dimcustomerid] [int] NULL,
[SSID] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sourcesystem] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssb_crmsystem_contact_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[contactguid] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fullname] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[emailprimary] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Data_Deletion_Request_TS] [datetime] NULL,
[Data_Deletion_TS] [datetime] NULL
)
GO
