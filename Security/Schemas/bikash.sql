CREATE SCHEMA [bikash]
AUTHORIZATION [dbo]
GO
GRANT EXECUTE ON SCHEMA:: [bikash] TO [db_readbikashschema]
GO
GRANT SELECT ON SCHEMA:: [bikash] TO [db_readbikashschema]
GO
GRANT EXECUTE ON SCHEMA:: [bikash] TO [db_writebikashschema]
GO
GRANT SELECT ON SCHEMA:: [bikash] TO [db_writebikashschema]
GO
GRANT ALTER ON SCHEMA:: [bikash] TO [db_writebikashschema]
GO
GRANT DELETE ON SCHEMA:: [bikash] TO [db_writebikashschema]
GO
GRANT INSERT ON SCHEMA:: [bikash] TO [db_writebikashschema]
GO
GRANT UPDATE ON SCHEMA:: [bikash] TO [db_writebikashschema]
GO
