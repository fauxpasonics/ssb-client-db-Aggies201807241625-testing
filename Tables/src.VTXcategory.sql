CREATE TABLE [src].[VTXcategory]
(
[ETL_ID] [int] NOT NULL,
[ETL_CreatedDate] [datetime] NOT NULL,
[ETL_SourceFileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[categoryid] [numeric] (20, 0) NULL,
[categorytypeid] [numeric] (10, 0) NULL,
[categoryname] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[categorydescription] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[categorystatus] [smallint] NULL,
[establishmenttype] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[establishmentkey] [numeric] (10, 0) NULL,
[parentid] [numeric] (10, 0) NULL,
[grandparentid] [numeric] (10, 0) NULL,
[greatgrandparentid] [numeric] (10, 0) NULL,
[imagepath] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastupdated] [datetime2] (6) NULL,
[lastupdatedby] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[createdate] [datetime2] (6) NULL,
[displayorder] [numeric] (10, 0) NULL,
[client_id] [numeric] (10, 0) NULL
)
GO
