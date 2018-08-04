CREATE TABLE [src].[VTXpaymenttranstypes]
(
[ETL_ID] [int] NOT NULL,
[ETL_CreatedDate] [datetime] NOT NULL,
[ETL_SourceFileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[paymenttranstype] [numeric] (10, 0) NULL,
[paymenttranstypedesc] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[paymenttypeprocessingmethod] [smallint] NULL,
[paymenttypewarnonexchange] [smallint] NULL,
[paymenttypefixedsystemvalue] [smallint] NULL,
[paymenttypeactive] [smallint] NULL,
[displayorder] [numeric] (10, 0) NULL,
[paymenttypevalidationpattern] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[paymenttypecheckpattern] [smallint] NULL
)
GO
