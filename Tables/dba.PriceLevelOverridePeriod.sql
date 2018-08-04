CREATE TABLE [dba].[PriceLevelOverridePeriod]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[PriceLevel] [nvarchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedDateUTC] [datetime] NULL,
[ExpirationDateUTC] [datetime] NULL
)
GO
ALTER TABLE [dba].[PriceLevelOverridePeriod] ADD CONSTRAINT [PK__PriceLev__3214EC07F6ADB086] PRIMARY KEY CLUSTERED  ([Id])
GO
