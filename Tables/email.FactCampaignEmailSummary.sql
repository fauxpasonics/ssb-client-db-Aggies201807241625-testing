CREATE TABLE [email].[FactCampaignEmailSummary]
(
[FactCampaignEmailSummaryId] [int] NOT NULL IDENTITY(-2, 1),
[DimCampaignId] [int] NULL,
[DimCampaignActivityTypeId] [int] NULL,
[DimEmailId] [int] NULL,
[ActivityTypeTotal] [int] NULL,
[ActivyTypeUnique] [bit] NULL,
[ActivityTypeMinDate] [datetime] NULL,
[ActivityTypeMaxDate] [datetime] NULL,
[CreatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__FactCampa__Creat__0DA4EB0F] DEFAULT (user_name()),
[CreatedDate] [datetime] NULL CONSTRAINT [DF__FactCampa__Creat__0E990F48] DEFAULT (getdate()),
[UpdatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__FactCampa__Updat__0BBCA29D] DEFAULT (user_name()),
[UpdatedDate] [datetime] NULL CONSTRAINT [DF__FactCampa__Updat__0CB0C6D6] DEFAULT (getdate())
)
GO
ALTER TABLE [email].[FactCampaignEmailSummary] ADD CONSTRAINT [PK__FactCamp__DF75612B8242EA15] PRIMARY KEY CLUSTERED  ([FactCampaignEmailSummaryId])
GO
CREATE NONCLUSTERED INDEX [idx_FactCampaignEmailSummary_DimCampaignActivityTypeId] ON [email].[FactCampaignEmailSummary] ([DimCampaignActivityTypeId])
GO
CREATE NONCLUSTERED INDEX [idx_FactCampaignEmailSummary_DimCampaignId] ON [email].[FactCampaignEmailSummary] ([DimCampaignId])
GO
CREATE NONCLUSTERED INDEX [idx_FactCampaignEmailSummary_DimEmailId] ON [email].[FactCampaignEmailSummary] ([DimEmailId])
GO
ALTER TABLE [email].[FactCampaignEmailSummary] WITH NOCHECK ADD CONSTRAINT [FK__FactCampa__DimCa__19D5B7CA] FOREIGN KEY ([DimCampaignId]) REFERENCES [email].[DimCampaign] ([DimCampaignId])
GO
ALTER TABLE [email].[FactCampaignEmailSummary] WITH NOCHECK ADD CONSTRAINT [FK__FactCampa__DimCa__17ED6F58] FOREIGN KEY ([DimCampaignActivityTypeId]) REFERENCES [email].[DimCampaignActivityType] ([DimCampaignActivityTypeId])
GO
ALTER TABLE [email].[FactCampaignEmailSummary] WITH NOCHECK ADD CONSTRAINT [FK__FactCampa__DimEm__18E19391] FOREIGN KEY ([DimEmailId]) REFERENCES [email].[DimEmail] ([DimEmailID])
GO
ALTER TABLE [email].[FactCampaignEmailSummary] NOCHECK CONSTRAINT [FK__FactCampa__DimCa__19D5B7CA]
GO
ALTER TABLE [email].[FactCampaignEmailSummary] NOCHECK CONSTRAINT [FK__FactCampa__DimCa__17ED6F58]
GO
ALTER TABLE [email].[FactCampaignEmailSummary] NOCHECK CONSTRAINT [FK__FactCampa__DimEm__18E19391]
GO
