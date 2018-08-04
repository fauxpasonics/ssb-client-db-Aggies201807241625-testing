SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
 
CREATE PROCEDURE [api].[sp_downstream_buckets_process] 
	@PostData NVARCHAR(MAX)  
	 
AS 
BEGIN 
 
	DECLARE 
		@ClientDB VARCHAR(50) = ''  
		, @sql NVARCHAR(MAX) = '' 
		, @response nvarchar(max)  
		, @ErrorMessage NVARCHAR(4000) 
		, @Type varchar (20) 
		, @UpdateKeyField varchar(10) 
		, @WinnerKeyField varchar(10) 
	 
 
 
		---drop table #baseData; 
		---drop table #downstream_process; 
 
 
 
---declare @PostData NVARCHAR(MAX)  = '{"ClientDb":"MDM_CLIENT_TEST","Type":"household merge","updatedata":[{"ssb_crmsystem_acct_id":"71D0541C-C971-4F76-BD98-941C020F6176","winner":"32415CDF-FEC2-4E7B-B23D-A746498891AE","excludefrommerge":true},{"ssb_crmsystem_acct_id":"881A1F9E-41CE-4BE9-B188-0F1A9D71CEA8","winner":"32415CDF-FEC2-4E7B-B23D-A746498891AE","excludefrommerge":false},{"ssb_crmsystem_acct_id":"CC434D15-4C46-4C68-B009-83D6FF3641F2","winner":"32415CDF-FEC2-4E7B-B23D-A746498891AE","excludefrommerge":false}]}' 
BEGIN TRY 
---drop table #baseData 
 
	SELECT element_id, sequenceNo, parent_ID, [Object_ID], NAME, StringValue, ValueType 
		INTO #baseData 
		FROM dbo.parseJSON(@PostData) 
 
		---select * from #baseData 
 
		---drop table #downstream_processing 
 
		SET @ClientDB = (select stringvalue from #baseData where name = 'ClientDb') 
			SET @Type = (select stringvalue from #baseData where name = 'Type') 
 
 
		If @Type like 'Contact %' 
		Begin 
		--build rows from parse		 
		set @sql = @sql + ' SELECT  
			 CAST(PVT.ssb_crmsystem_contact_id AS varchar(50)) AS ssb_id 
			 , cast(winner as varchar(50)) as winner 
			, CAST(downstream_id AS INT) AS downstream_id 
			, CAST(excludefrommerge AS varchar(20)) AS excludefrommerge 
			into #downstream_process 
		--SELECT * 
		FROM ( 
				SELECT Name 
					, StringValue 
					, parent_ID 
				FROM #baseData 
			) z 
		PIVOT 
			( Max(StringValue) for Name in ( 
				---[ClientDB] 
				 [ssb_crmsystem_contact_id] 
				 , [winner] 
				, [downstream_id] 
				, [excludefrommerge]) 
			) as PVT 
			where ssb_crmsystem_contact_id is not null;' 
		End 
		 
		else if @Type like 'Account %' or @Type like 'Household %' 
		Begin 
		--build rows from parse		 
			set @sql = ' SELECT 
				---CAST(ClientDB AS VARCHAR(50)) AS ClientDB  
				 CAST(PVT.ssb_crmsystem_acct_id AS varchar(50)) AS ssb_id 
				 , cast(winner as varchar(50)) as winner 
				, CAST(downstream_id AS INT) AS downstream_id 
				, CAST(excludefrommerge AS varchar(20)) AS excludefrommerge 
				into #downstream_process 
			--SELECT * 
			FROM ( 
					SELECT Name 
						, StringValue 
						, parent_ID 
					FROM #baseData 
				) z 
			PIVOT 
				( Max(StringValue) for Name in ( 
					---[ClientDB] 
					 [ssb_crmsystem_acct_id] 
					 , [winner] 
					, [downstream_id] 
					, [excludefrommerge]) 
				) as PVT 
				where ssb_crmsystem_acct_id is not null;' 
		end 
 
		---set @sql = @sql + ' select * from #downstream_process' 
		 
	 
			---select * from #downstream_process 
 
 
			IF (SELECT @@VERSION) LIKE '%Azure%' 
				SET @ClientDB = '' 
			ELSE IF (SELECT @@VERSION) NOT LIKE '%Azure%' 
				SET @ClientDB = @ClientDB + '.' 
 
			If @type in ('Contact Merge', 'Account Merge', 'Household Merge')  
				Begin  
					set @UpdateKeyField = 'old' 
					set @WinnerKeyField = 'new' 
				End 
				else 
				begin 
					set @UpdateKeyField = 'new' 
					set @WinnerKeyField = 'old' 
				end 
 
			If @Type = 'Contact Merge' 
				Begin  
				---- Add Merge Exclusions to forceunmerge 
					set @sql = @sql + + CHAR(13) + CHAR(13) 
				+   'Declare @forced_id varchar(50) = newID() ' 
				+	'Insert into ' + @clientdb + 'mdm.forceunmergeids (DIMCUSTOMERID, FORCED_CONTACT_ID, CreatedBy, PriorGrouping) ' 
				+	'Select a.dimcustomerid, case when new != old then old else @forced_id end as forced_contact_id, ''DownStream Bucketting UI'', new ' 
				+	'from ' + @clientdb + 'mdm.downstream_bucketting  a ' 
				+	'left join ' + @clientdb + 'mdm.forceunmergeids c ' 
				+	'on a.dimcustomerid = c.dimcustomerid ' 
				+	' where old in (select ssb_crmsystem_contact_id from #downstream_process where excludefrommerge = ''true'') ' 
				+ ' and downstream_id in (select downstream_id from #downstream_process) and processed = 0; ' 
				End 
			Else if @Type in ('Account Merge', 'Account Split', 'Household Merge', 'Household Split')  
				Begin 
					set @sql = @sql + + CHAR(13) + CHAR(13) 
				+   'Declare @forced_id varchar(50) = newID() ' 
				+	'Insert into ' + @clientdb  
				If @type in ('Account Merge', 'Account Split') 
				Begin 
					set @sql = @sql +   'mdm.forceAcctGrouping ' 
				End 
				else 
				Begin 
					set @sql = @sql +   'mdm.forceHouseholdGrouping ' 
				End 
				set @sql = @sql +   ' (DIMCUSTOMERID, GroupingID, CreatedBy, PriorGrouping) ' 
				+	'Select a.dimcustomerid, ' 
				if @Type in ('Account Merge', 'Household Merge')  
					Begin 
						set @sql = @sql  +	' case when new != old then old else @forced_id end as GroupingId ' 
					end 
				else 
					begin 
						set @sql = @sql  +	'  @forced_id as GroupingId ' 
					end 
				set @sql = @sql  +	', ''DownStream Bucketting UI'', new '   
				+  'from ' + @clientdb + 'mdm.downstream_bucketting  a ' 
				+	'left join ' + @clientdb 
				If @type in ('Account Merge', 'Account Split') 
				Begin 
					set @sql = @sql +   'mdm.forceAcctGrouping ' 
				End 
				else 
				Begin 
					set @sql = @sql +   'mdm.forceHouseholdGrouping ' 
				End 
				set @sql = @sql + ' c ' 
				+	'on a.dimcustomerid = c.dimcustomerid ' 
				+	' where ' + @UpdateKeyField  
				+   ' in (select ssb_id from #downstream_process where excludefrommerge = ''true'')  ' 
				+   ' and ' + @WinnerKeyField + ' in (select winner from #downstream_process where excludefrommerge = ''true'') ' 
				+	' and processed = 0; ' 
				End 
			Else  
				Begin 
				--Add split exclusions to Api.Incoming_merge (force merge) 
					set @sql = @sql + + CHAR(13) + CHAR(13) 
					+ ' with winner as ( 
					select top 1 DIMCUSTOMERID as winning_dimcustomerid, ssb_id as winning_guid  
					from #downstream_process a 
					inner join ' + @clientdb + 'mdm.downstream_bucketting b 
					on a.downstream_id = b.downstream_id 
					where excludefrommerge = ''true''  and processed = 0) 
					insert into ' + @clientdb + 'api.incoming_merge (winning_dimcustomerid, winning_guid, loser_dimcustomerid,	loser_guid, createddate, guidType) 
					select winning_dimcustomerid, winning_guid,  
					dimcustomerid as loser_dimcustomerid, ssb_crmsystem_contact_id as Loser_guid, current_timestamp, ''contact'' 
					from winner, #downstream_process a 
					inner join ' + @clientdb + 'mdm.downstream_bucketting b 
					on a.downstream_id = b.downstream_id 
					where excludefrommerge = ''true''  and processed = 0 and winning_dimcustomerid != b.dimcustomerid; ' 
 
				End 
				 
				---Mark records as processed 
			set @sql = @sql + + + CHAR(13) + CHAR(13) 
			+	'update ' + @ClientDB + 'mdm.downstream_bucketting 
					set processed = 1, 
					processed_dt = current_timestamp, 
					processing_response = ''' + @PostDATA+ ''' 
					where ' + @UpdateKeyField + ' in (select ssb_id from #downstream_process)  
					and ' + @WinnerKeyField + ' in (select winner from #downstream_process) 
					and processed = 0;';				 
 
 
---select * from #baseData 
---select * from #downstream_process 
	 
---SELECT @sql 
 
EXEC sp_executesql @sql 
 
	END TRY 
	BEGIN CATCH 
	    SELECT @ErrorMessage = ERROR_MESSAGE() 
		SET @response = 'There was an error attempting to process this data.' + CASE WHEN ISNULL(@ErrorMessage,'') != '' THEN ' ' +					@ErrorMessage ELSE '' END  
	END CATCH	 
 
	IF @response IS NULL  
	BEGIN 
		Set @response = 'Success' 
	End  
 
 
 
	SELECT @response as responsetxt 
 
 
 
END
GO
