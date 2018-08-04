SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
CREate Procedure [api].[sp_GetSubjectAccessRequests] 
(@clientdb varchar(50)) 
as 
 
Begin 
 
---Declare @clientdb varchar(50) = 'mdm_client_dev' 
 
IF (SELECT @@VERSION) LIKE '%Azure%' 
BEGIN 
SET @ClientDB = '' 
END 
 
IF (SELECT @@VERSION) NOT LIKE '%Azure%' 
BEGIN 
SET @ClientDB = @ClientDB + '.' 
END 
 
Declare @sql nvarchar(max)  = '' 
 
Set @sql = @sql  
+' Select c.ssb_crmsystem_contact_id, a.dimcustomerid, b.ssid, b.sourcesystem, b.fullname, Subject_Access_Request_TS, Subject_Access_Request_Source '+ CHAR(13) 
+' from ' + @clientdb + 'dbo.DimCustomerPrivacy a'+ CHAR(13) 
+'  inner join ' + @clientdb + 'dbo.dimcustomer b'+ CHAR(13) 
+'  on a.dimcustomerid = b.dimcustomerid '+ CHAR(13) 
+'  inner join ' + @clientdb + 'dbo.dimcustomerssbid c'+ CHAR(13) 
+'  on a.dimcustomerid = c.dimcustomerid'+ CHAR(13) 
+' where subject_access_request_ts is not null'+ CHAR(13) 
 
 
----SELECT @SQL 
		EXEC sp_executesql @sql 
END
GO
