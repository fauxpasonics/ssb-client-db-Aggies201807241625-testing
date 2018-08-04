CREATE TABLE [ctaylor].[tbl_test2]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[dateadded] [datetime] NULL CONSTRAINT [DF__tbl_test2__datea__5D01B3B4] DEFAULT (getdate()),
[productid] [int] NULL,
[quantity] [int] NULL
)
GO
ALTER TABLE [ctaylor].[tbl_test2] ADD CONSTRAINT [PK__tbl_test__3213E83F90B07CB0] PRIMARY KEY CLUSTERED  ([id])
GO
