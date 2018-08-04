CREATE ROLE [db_readbikashschema]
AUTHORIZATION [dbo]
GO
EXEC sp_addrolemember N'db_readbikashschema', N'psurber_athletics.tamu.edu'
GO
