CREATE ROLE [db_ReadAmySchema]
AUTHORIZATION [dbo]
GO
EXEC sp_addrolemember N'db_ReadAmySchema', N'psurber_athletics.tamu.edu'
GO
EXEC sp_addrolemember N'db_ReadAmySchema', N'svc_12thManISA'
GO
