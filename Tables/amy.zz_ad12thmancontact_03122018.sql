CREATE TABLE [amy].[zz_ad12thmancontact_03122018]
(
[contactid] [int] NULL,
[adnumber] [int] NULL,
[adnumber_char] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
CREATE NONCLUSTERED INDEX [zz_ad12thmancontact_03122018_ind1] ON [amy].[zz_ad12thmancontact_03122018] ([adnumber_char])
GO
