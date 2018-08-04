SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [api].[sp_downstream_buckets]
	@ClientDB varchar(50)
	,@Type VARCHAR(50) 
	
AS
BEGIN
	---DECLARE @ClientDb VARCHAR(50) = 'MDM_CLIENT_TEST'
	---DECLARE @Type varchar(50) = 'contact merge'



	IF (SELECT @@VERSION) LIKE '%Azure%'
		SET @ClientDB = ''
	ELSE IF (SELECT @@VERSION) NOT LIKE '%Azure%'
		SET @ClientDB = @ClientDB + '.'

	Declare @id_field varchar(100) 
	Declare @flag_field varchar(100)
	Declare @keyfield varchar(10)
	Declare @newfield varchar(10)


	If left(@type, 1) = 'C' 
	begin
		set @id_field = 'ssb_crmsystem_contact_id'
		set @flag_field = 'ssb_crmsystem_primary_flag'
	end
	else if left(@type, 1) = 'H' 
		begin
		set @id_field = 'ssb_crmsystem_household_id'
		set @flag_field = 'ssb_crmsystem_household_primary_flag'
	end
	Else
	begin
		set @id_field = 'ssb_crmsystem_acct_id'
		set @flag_field = 'ssb_crmsystem_acct_primary_flag'
	end

	if @type in ('Contact Merge', 'Account Merge', 'Household Merge') 
	Begin 
		set @keyfield = 'new'
		set @newfield = 'old'

	End
	else
	begin
		set @keyfield = 'old'
		set @newfield = 'new'
	end


declare @sql nvarchar(max)


set @sql = '
declare @keyguid varchar(500) =(select top 1 ' + @keyfield + ' from ' + @clientdb + 'mdm.downstream_bucketting
	where actiontype = ''' + @Type + ''' and processed = 0 
	order by mdm_run_dt)

declare @minrundate varchar(20) = (select cast(min(mdm_run_dt) as date) from  ' + @clientdb + 'mdm.downstream_bucketting 
	where actiontype = ''' + @Type + ''' and processed = 0)

declare @reccnt varchar(10) = (select sum(cnt) from (
	select isnull(count(distinct ' + @keyfield + '), 0) as cnt from ' + @clientdb + 'mdm.downstream_bucketting
	where actiontype = ''' + @Type + ''' and processed = 0 
	group by cast(mdm_run_dt as date) ) a)

select @reccnt as recordcount, old, new, mdm_run_dt, c.dimcustomerid,  c.ssid, c.sourcesystem, c.fullname, c.companyname, c.emailprimary, c.phoneprimary, c.addressprimarystreet, c.addressprimarycity, c.addressprimarystate, 
c.addressprimarycountry, c.addressprimaryzip, c.customer_matchkey,  '
if @type = 'Contact Merge'
begin 
set @sql = @sql + ' d.ssb_crmsystem_primary_flag as ContactType '
end 
else
begin 
set @sql = @sql + ' primaryflag as ContactType '
end


/*
if @type in ('Contact Merge', 'Account Merge', 'Household Merge') 
	Begin 
		set @sql = @sql + ' case when new = old then ''true'' else ''false'' end as Winner '
	End
Else
	Begin 
		set @sql = @sql + ' case when a.primaryflag = 1 then ''true'' else ''false'' end as Winner '
	End
*/

set @sql = @sql + ',  a.ssb_crmsystem_contact_id , a.downstream_id
from ' + @clientdb + 'mdm.downstream_bucketting a with (nolock) 
inner join ' + @clientdb + 'dbo.dimcustomer c  with (nolock)
on a.dimcustomerid = c.dimcustomerid
inner join mdm_client_test.dbo.dimcustomerssbid d with (nolock)
on c.dimcustomerid = d.dimcustomerid
where ' + @keyfield + ' = @keyguid and actiontype = ''' + @Type + ''' and processed = 0 
and cast(mdm_run_dt as date) =  @minrundate '

if @type not in ('Contact Merge', 'Contact Split')
set @sql = @sql + ' and a.primaryflag = 1'

/*
if @type in ('Contact Merge', 'Account Merge', 'Household Merge') 
	Begin 
		set @sql = @sql + ' and a.primaryflag = 1 ' 
	End
Else if @type in ('Contact Split', 'Account Split', 'Household Split')
	Begin 
		set @sql = @sql + ' and d.' + @flag_field + ' = 1 '
	End
*/
  

----SELECT @sql

	EXEC sp_executesql @sql

END
GO
