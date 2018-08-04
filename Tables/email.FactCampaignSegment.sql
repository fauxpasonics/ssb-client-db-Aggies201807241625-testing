CREATE TABLE [email].[FactCampaignSegment]
(
[FactCampaignSegmentId] [int] NOT NULL IDENTITY(-2, 1),
[DimCampaignId] [int] NULL,
[DimSegmentId] [int] NULL,
[CreatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__FactCampa__Creat__11757BF3] DEFAULT (user_name()),
[CreatedDate] [datetime] NULL CONSTRAINT [DF__FactCampa__Creat__1269A02C] DEFAULT (getdate()),
[UpdatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__FactCampa__Updat__0F8D3381] DEFAULT (user_name()),
[UpdatedDate] [datetime] NULL CONSTRAINT [DF__FactCampa__Updat__108157BA] DEFAULT (getdate())
)
GO
ALTER TABLE [email].[FactCampaignSegment] ADD CONSTRAINT [PK__FactCamp__1324ECD5A43E1630] PRIMARY KEY CLUSTERED  ([FactCampaignSegmentId])
GO
CREATE NONCLUSTERED INDEX [idx_FactCampaignSegment_DimCampaignId] ON [email].[FactCampaignSegment] ([DimCampaignId])
GO
CREATE NONCLUSTERED INDEX [idx_FactCampaignSegment_DimSegmentId] ON [email].[FactCampaignSegment] ([DimSegmentId])
GO
ALTER TABLE [email].[FactCampaignSegment] WITH NOCHECK ADD CONSTRAINT [FK__FactCampa__DimCa__1BBE003C] FOREIGN KEY ([DimCampaignId]) REFERENCES [email].[DimCampaign] ([DimCampaignId])
GO
ALTER TABLE [email].[FactCampaignSegment] WITH NOCHECK ADD CONSTRAINT [FK__FactCampa__DimSe__1AC9DC03] FOREIGN KEY ([DimSegmentId]) REFERENCES [email].[DimSegment] ([DimSegmentId])
GO
ALTER TABLE [email].[FactCampaignSegment] NOCHECK CONSTRAINT [FK__FactCampa__DimCa__1BBE003C]
GO
ALTER TABLE [email].[FactCampaignSegment] NOCHECK CONSTRAINT [FK__FactCampa__DimSe__1AC9DC03]
GO
