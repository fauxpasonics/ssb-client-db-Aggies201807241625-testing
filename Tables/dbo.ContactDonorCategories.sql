CREATE TABLE [dbo].[ContactDonorCategories]
(
[ContactID] [int] NOT NULL,
[CategoryID] [int] NOT NULL,
[Value] [varchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
ALTER TABLE [dbo].[ContactDonorCategories] ADD CONSTRAINT [PK_ContactDonorCategory_d7a290db-c0a3-4181-9c44-2aa4c32544d8] PRIMARY KEY CLUSTERED  ([ContactID], [CategoryID])
GO
