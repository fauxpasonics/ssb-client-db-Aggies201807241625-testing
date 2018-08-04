CREATE TABLE [ods].[VTXordergroups_mergedaccounts_update]
(
[ETL_ID] [int] NOT NULL IDENTITY(1, 1),
[ETL_CreatedDate] [datetime] NOT NULL CONSTRAINT [DF__VTXorderg__ETL_C__59F03CDF] DEFAULT (getdate()),
[ordergroup] [numeric] (10, 0) NULL,
[customerid] [numeric] (38, 10) NULL
)
GO
ALTER TABLE [ods].[VTXordergroups_mergedaccounts_update] ADD CONSTRAINT [PK__VTXorder__7EF6BFCDE4568D97] PRIMARY KEY CLUSTERED  ([ETL_ID])
GO
