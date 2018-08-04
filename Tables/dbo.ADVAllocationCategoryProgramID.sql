CREATE TABLE [dbo].[ADVAllocationCategoryProgramID]
(
[CategoryID] [int] NOT NULL,
[ProgramID] [int] NOT NULL
)
GO
ALTER TABLE [dbo].[ADVAllocationCategoryProgramID] ADD CONSTRAINT [PK__ADVAlloc__8E5B6C28E8722595] PRIMARY KEY CLUSTERED  ([CategoryID], [ProgramID])
GO
