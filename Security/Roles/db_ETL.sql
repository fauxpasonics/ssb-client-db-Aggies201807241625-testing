CREATE ROLE [db_ETL]
AUTHORIZATION [dbo]
GO
EXEC sp_addrolemember N'db_ETL', N'svcETL'
GO
GRANT EXECUTE TO [db_ETL]
