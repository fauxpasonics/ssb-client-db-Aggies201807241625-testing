CREATE TABLE [ods].[VTXcomments]
(
[ETL_ID] [int] NOT NULL IDENTITY(1, 1),
[ETL_CreatedDate] [datetime] NOT NULL,
[ETL_UpdatedDate] [datetime] NULL,
[ETL_IsDeleted] [bit] NULL,
[ETL_DeletedDate] [datetime] NULL,
[ETL_DeltaHashKey] [binary] (32) NULL,
[ETL_SourceFileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[commentid] [numeric] (10, 0) NULL,
[description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastupdated] [datetime2] (6) NULL
)
GO
ALTER TABLE [ods].[VTXcomments] ADD CONSTRAINT [PK__VTXcomme__7EF6BFCDA07B9253] PRIMARY KEY CLUSTERED  ([ETL_ID])
GO
CREATE NONCLUSTERED INDEX [IDX_VTXcomments_commentid] ON [ods].[VTXcomments] ([commentid])
GO
