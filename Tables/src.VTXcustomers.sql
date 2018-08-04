CREATE TABLE [src].[VTXcustomers]
(
[ETL_ID] [int] NOT NULL,
[ETL_CreatedDate] [datetime] NOT NULL,
[ETL_SourceFileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[id] [numeric] (38, 10) NULL,
[accountnumber] [nvarchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastname] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[firstname] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[middle] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[phone1] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[phone2] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address1] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address2] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[city] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[state] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zip] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[initdate] [datetime2] (6) NULL,
[lastupdate] [datetime2] (6) NULL,
[companyname] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[birthday] [datetime2] (6) NULL,
[fullname] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prefix] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[suffix] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[phone3] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[phone1type] [numeric] (38, 10) NULL,
[phone2type] [numeric] (38, 10) NULL,
[phone3type] [numeric] (38, 10) NULL,
[salutation] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[search] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[careof] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stateid] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sentwelcomemessage] [numeric] (38, 10) NULL,
[optedin] [numeric] (38, 10) NULL,
[addressid] [numeric] (38, 10) NULL,
[fax] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isfemale] [smallint] NULL,
[country] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[usersearch] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[legacyid] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[convertfsunpaiddefault] [smallint] NULL
)
GO
CREATE NONCLUSTERED INDEX [IX_accountnumber] ON [src].[VTXcustomers] ([accountnumber])
GO
ALTER INDEX [IX_accountnumber] ON [src].[VTXcustomers] DISABLE
GO
