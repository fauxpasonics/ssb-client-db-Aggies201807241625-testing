CREATE TABLE [prodcopy].[OpportunityLineItem]
(
[Id] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OpportunityId] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SortOrder] [int] NULL,
[PricebookEntryId] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Product2Id] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProductCode] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Name] [nvarchar] (376) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Quantity] [float] NULL,
[TotalPrice] [float] NULL,
[UnitPrice] [float] NULL,
[ListPrice] [float] NULL,
[ServiceDate] [date] NULL,
[Description] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedDate] [datetime] NULL,
[CreatedById] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastModifiedDate] [datetime] NULL,
[LastModifiedById] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SystemModstamp] [datetime] NULL,
[IsDeleted] [bit] NULL,
[Full_Opportunity_Product_ID__c] [nvarchar] (1300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Donation__c] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Is_OP_Donation__c] [bit] NULL,
[Is_OP_Season_Ticket__c] [bit] NULL,
[Season_Ticket__c] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[copyloaddate] [datetime] NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
ALTER TABLE [prodcopy].[OpportunityLineItem] ADD CONSTRAINT [PK__Opportun__3214EC07937094BA] PRIMARY KEY CLUSTERED  ([Id])
GO
