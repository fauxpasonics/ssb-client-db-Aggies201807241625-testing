CREATE TABLE [amy].[ProgramGLMappings]
(
[programid] [int] NULL,
[Allocation] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GL] [int] NULL,
[R] [int] NULL,
[Fd] [int] NULL,
[CC] [int] NULL,
[allocationid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
CREATE NONCLUSTERED INDEX [ProgramGLMappings_ind01] ON [amy].[ProgramGLMappings] ([programid])
GO
