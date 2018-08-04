CREATE TABLE [apietl].[MailChimp_ListMembers_Prod_members_location_2]
(
[ETL__MailChimp_ListMembers_Prod_members_location_id] [uniqueidentifier] NOT NULL,
[ETL__MailChimp_ListMembers_Prod_members_id] [uniqueidentifier] NULL,
[latitude] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[longitude] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gmtoff] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dstoff] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[country_code] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[timezone] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
ALTER TABLE [apietl].[MailChimp_ListMembers_Prod_members_location_2] ADD CONSTRAINT [PK__MailChim__8639B108E2C2F674] PRIMARY KEY CLUSTERED  ([ETL__MailChimp_ListMembers_Prod_members_location_id])
GO
