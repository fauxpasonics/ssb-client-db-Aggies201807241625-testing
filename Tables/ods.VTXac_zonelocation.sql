CREATE TABLE [ods].[VTXac_zonelocation]
(
[ETL_ID] [int] NOT NULL IDENTITY(1, 1),
[ETL_CreatedDate] [datetime] NOT NULL,
[ETL_UpdatedDate] [datetime] NULL,
[ETL_IsDeleted] [bit] NULL,
[ETL_DeletedDate] [datetime] NULL,
[ETL_DeltaHashKey] [binary] (32) NULL,
[ETL_SourceFileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixeventid] [numeric] (10, 0) NULL,
[tixeventzoneid] [smallint] NULL,
[locationid] [int] NULL
)
GO
ALTER TABLE [ods].[VTXac_zonelocation] ADD CONSTRAINT [PK__VTXac_zo__7EF6BFCDAF248A07] PRIMARY KEY CLUSTERED  ([ETL_ID])
GO
