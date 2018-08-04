CREATE SCHEMA [client]
AUTHORIZATION [dbo]
GO
GRANT EXECUTE ON SCHEMA:: [client] TO [CI_ClientAccess]
GO
GRANT REFERENCES ON SCHEMA:: [client] TO [CI_ClientAccess]
GO
GRANT SELECT ON SCHEMA:: [client] TO [CI_ClientAccess]
GO
GRANT VIEW DEFINITION ON SCHEMA:: [client] TO [CI_ClientAccess]
GO
GRANT EXECUTE ON SCHEMA:: [client] TO [CI_ClientWriter]
GO
GRANT REFERENCES ON SCHEMA:: [client] TO [CI_ClientWriter]
GO
GRANT ALTER ON SCHEMA:: [client] TO [CI_ClientWriter]
GO
GRANT DELETE ON SCHEMA:: [client] TO [CI_ClientWriter]
GO
GRANT INSERT ON SCHEMA:: [client] TO [CI_ClientWriter]
GO
GRANT UPDATE ON SCHEMA:: [client] TO [CI_ClientWriter]
GO
