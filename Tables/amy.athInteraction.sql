CREATE TABLE [amy].[athInteraction]
(
[id] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[email] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[contacttype] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[contactgrouptype] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[contact_date] [datetime] NULL,
[create_date] [datetime] NULL,
[optin] [bit] NULL,
[contacttypeid] [uniqueidentifier] NULL,
[macid] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
CREATE NONCLUSTERED INDEX [athInteractionInd91] ON [amy].[athInteraction] ([contacttype])
GO
CREATE NONCLUSTERED INDEX [athInteractionInd02] ON [amy].[athInteraction] ([id])
GO
