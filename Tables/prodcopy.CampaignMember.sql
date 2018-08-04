CREATE TABLE [prodcopy].[CampaignMember]
(
[Id] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsDeleted] [bit] NULL,
[CampaignId] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LeadId] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContactId] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HasResponded] [bit] NULL,
[CreatedDate] [datetime] NULL,
[CreatedById] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastModifiedDate] [datetime] NULL,
[LastModifiedById] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SystemModstamp] [datetime] NULL,
[FirstRespondedDate] [date] NULL,
[Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Full_Campaign_Member_ID__c] [nvarchar] (1300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Salutation] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Title] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Street] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PostalCode] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Country] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Phone] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fax] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MobilePhone] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DoNotCall] [bit] NULL,
[HasOptedOutOfEmail] [bit] NULL,
[HasOptedOutOfFax] [bit] NULL,
[LeadSource] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CompanyOrAccount] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Type] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LeadOrContactId] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LeadOrContactOwnerId] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[copyloaddate] [datetime] NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
ALTER TABLE [prodcopy].[CampaignMember] ADD CONSTRAINT [PK__Campaign__3214EC07CE475214] PRIMARY KEY CLUSTERED  ([Id])
GO