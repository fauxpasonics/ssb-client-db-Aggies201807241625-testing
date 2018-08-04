CREATE TABLE [dtimber].[tbl_test2]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[dateadded] [datetime] NULL CONSTRAINT [DF__tbl_test2__datea__5FDE205F] DEFAULT (getdate()),
[productid] [int] NULL,
[quantity] [int] NULL
)
GO
ALTER TABLE [dtimber].[tbl_test2] ADD CONSTRAINT [PK__tbl_test__3213E83FF78C6C78] PRIMARY KEY CLUSTERED  ([id])
GO
