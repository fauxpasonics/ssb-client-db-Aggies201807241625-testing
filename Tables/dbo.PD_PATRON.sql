CREATE TABLE [dbo].[PD_PATRON]
(
[ETLSID] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
[PATRON] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NAME] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SUFFIX] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TITLE] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NAME2] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SUFFIX2] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TITLE2] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ANNOUNCE] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STATUS] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[MAIL_NAME] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VIP] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[EXTERNAL_NUMBER] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COMMENTS] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TAG] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RELEASE] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SOURCE] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[MARITAL_STATUS] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[INTERNET_PROFILE] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MAGSTRIPE_ID] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ENTRY_USER] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ENTRY_DATETIME] [datetime] NULL,
[HOUSEHOLD_INCOME] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NICKNAME1] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NICKNAME2] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MAIDEN1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MAIDEN2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GENDER1] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GENDER2] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ETHNIC1] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[ETHNIC2] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[RELIGION1] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[RELIGION2] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[BIRTH_DATE1] [datetime] NULL,
[BIRTH_DATE2] [datetime] NULL,
[BIRTH_PLACE1] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BIRTH_PLACE2] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EV_EMAIL] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LANGUAGE1] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LANGUAGE2] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KEYWORDS] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UD1] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UD2] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UD3] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UD4] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UD5] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UD6] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UD7] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UD8] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UD9] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UD10] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UD11] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UD12] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UD13] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UD14] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UD15] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UD16] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EMAIL_OK] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MERGED] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LAST_USER] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
[LAST_DATETIME] [datetime] NULL,
[ZID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SOURCE_ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EXPORT_DATETIME] [datetime] NULL,
[ETL_Sync_DeltaHashKey] [binary] (32) NULL
)
GO
ALTER TABLE [dbo].[PD_PATRON] ADD CONSTRAINT [PK_PD_PATRON] PRIMARY KEY CLUSTERED  ([ETLSID], [PATRON])
GO
CREATE NONCLUSTERED INDEX [IDX_ETLSID] ON [dbo].[PD_PATRON] ([ETLSID])
GO
CREATE NONCLUSTERED INDEX [IDX_PATRON] ON [dbo].[PD_PATRON] ([PATRON])
GO
