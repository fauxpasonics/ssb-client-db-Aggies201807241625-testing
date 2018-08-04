CREATE TABLE [amy].[tixsysseatstatuscodes]
(
[tixsysseatstatuscode] [int] NULL,
[tixsysseatstatusdesc] [nvarchar] (78) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsysseatstatusdisplayorder] [int] NULL,
[tixsysseatstatusinitdate] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsysseatstatuslastupdwhen] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsysseatstatuslastupdwho] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsysseatstatustype] [int] NULL,
[tixsysseatstatuscontrol] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsysseatstatuscolors] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsysseatstatustextdesc] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsysseatstatushistoryreconly] [int] NULL,
[tixsysseatstatussystemonlyflag] [int] NULL,
[tixsysseatstatusmodatnextlevel] [int] NULL,
[tixsysseatstatussubtype] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tixsysseatstatuspkgonlyflag] [int] NULL,
[tixsyshiddenstatus] [int] NULL
)
GO
CREATE NONCLUSTERED INDEX [aj_tixsysseatstatuscodeIND01] ON [amy].[tixsysseatstatuscodes] ([tixsysseatstatuscode])
GO
