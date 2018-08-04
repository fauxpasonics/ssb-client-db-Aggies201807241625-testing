CREATE TABLE [mdm].[mdm.namephonehash_drop]
(
[NamePhone_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PhoneHash] [varchar] (585) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
ALTER TABLE [mdm].[mdm.namephonehash_drop] ADD CONSTRAINT [PK_NamePhoneHash] PRIMARY KEY CLUSTERED  ([NamePhone_id])
GO
CREATE NONCLUSTERED INDEX [ix_namephonehash_PhoneHash] ON [mdm].[mdm.namephonehash_drop] ([PhoneHash])
GO
