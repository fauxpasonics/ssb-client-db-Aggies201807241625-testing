SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
 
Create Procedure [api].[sp_GetDataDeleteRequests] 
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
+' select ssb_crmsystem_contact_id, dimcustomerid, ssid, sourcesystem, fullname, Data_Deletion_Request_TS, Data_Deletion_TS, cast(null as varchar(100)) as data_deletion_incomplete_reason from mdm.PrivacyLog a' + char(13) 
+' where a.clientname = ''' + @clientdb + '''' + char(13) 
+' Union ' + char(13) 
+' Select c.SSB_CRMSYSTEM_CONTACT_ID, a.dimcustomerid, b.ssid, b.sourcesystem, b.fullname, Data_Deletion_Request_TS, Data_Deletion_Completed_TS, Data_Deletion_Incomplete_Reason ' + char(13) 
+' from ' + @clientdb + 'dbo.DimCustomerPrivacy a' + char(13) 
+' inner join '+ @clientDb + 'dbo.dimcustomer b ' + char(13) 
+' on a.dimcustomerid = b.dimcustomerid' + char(13) 
+' inner join '+ @clientDb + 'dbo.dimcustomerssbid c' + char(13) 
+' on a.dimcustomerid = c.dimcustomerid' + char(13) 
+' where data_deletion_request_ts is not null and data_deletion_completed_ts is null' + char(13) 
+' order by data_deletion_request_ts, ssb_crmsystem_contact_id' + char(13) 
 
----SELECT @SQL 
		EXEC sp_executesql @sql 
END
GO
