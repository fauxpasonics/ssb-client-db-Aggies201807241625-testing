CREATE ROLE [db_writebikashschema]
AUTHORIZATION [dbo]
GO
EXEC sp_addrolemember N'db_writebikashschema', N'bmandal_athletics.tamu.edu'
GO
GRANT CREATE FUNCTION TO [db_writebikashschema]
GRANT CREATE PROCEDURE TO [db_writebikashschema]
GRANT CREATE TABLE TO [db_writebikashschema]
GRANT CREATE VIEW TO [db_writebikashschema]
GRANT SHOWPLAN TO [db_writebikashschema]
GRANT VIEW DEFINITION TO [db_writebikashschema]
