CREATE TABLE [amy].[historical_priority_point_pacconv]
(
[patron] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rank] [int] NULL,
[points] [float] NULL,
[EntryDate] [datetime] NOT NULL
)
GO
CREATE NONCLUSTERED INDEX [historical_priority_point_pacconv_ind01] ON [amy].[historical_priority_point_pacconv] ([patron])
GO
