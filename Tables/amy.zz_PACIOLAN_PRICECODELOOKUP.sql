CREATE TABLE [amy].[zz_PACIOLAN_PRICECODELOOKUP]
(
[AXSPriceCode] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PaciolanPriceType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ZeroException] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewPricetype] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewPricetype_alt2] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eventid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Season] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
CREATE NONCLUSTERED INDEX [zz_PACIOLAN_PRICECODELOOKUP_innd01] ON [amy].[zz_PACIOLAN_PRICECODELOOKUP] ([eventid], [AXSPriceCode])
GO
