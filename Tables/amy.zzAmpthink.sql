CREATE TABLE [amy].[zzAmpthink]
(
[FIRST_NAME] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LAST_NAME] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PERSISTENT_ID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LOCATION_NAME] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ADDRESS] [nvarchar] (52) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CITY] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STATE] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ZIP] [int] NULL
)
GO
CREATE NONCLUSTERED INDEX [zzAmpthink_fn_ln_ind] ON [amy].[zzAmpthink] ([FIRST_NAME], [LAST_NAME])
GO
