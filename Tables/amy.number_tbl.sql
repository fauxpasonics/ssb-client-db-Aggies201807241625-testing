CREATE TABLE [amy].[number_tbl]
(
[num] [bigint] NULL
)
GO
CREATE NONCLUSTERED INDEX [number_tbl_ind] ON [amy].[number_tbl] ([num])
GO
