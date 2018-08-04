SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [amy].[ath_contactsupdate] as 
  begin   
      --contactinfo
    merge athcontacts cc 
    using (
    select  --v.email, u.email, c.email,
   -- v.accountnumber ,  v.lastname, v.firstname, v.phone1, v.email, v.zip, v.state, v.city, v.address1, v.address2, 
 distinct   u.id,
   max(c.ADNumber) adnumber, min( c.Status) status, min(c.AccountName) accountname, min(c.FirstName) firstname, min(c.LastName) lastname,
   c.Email , 1 DonorInd, 1 TicketingInd,
   max( c.AdjustedPP) adjustedpp, max(c.LifetimeGiving) lifetimegiving, max(c.PPRank) pprank ,max( c.SetupDate) setupdate,  u.creation_source
   --   u.*
    --from ods.VTXcustomers  v join  
    from amy.athContacts u 
    join  advcontact c on  c.email = u.email
    where  DonorNumber is null and c.adnumber is not null  and c.email not in (select email from  amy.athContacts group by email having count(*) > 1)
    and c.email not in (select email from  advcontact group by email having count(*) > 1)
   /* ('codyjbuczyna@gmail.com',
'Jon.Bennett140014@gmail.com',
'jprocterii@aol.com',
'lradebaugh@hotmail.com',
'rluckystarranch@gmail.com') */
group by u.id, c.email,  u.creation_source
    ) aa 
    on aa.id = cc.id  --and cc.donornumber is null
when matched 
then update
 set cc.donornumber = aa.ADNumber, 
   cc.donoraccountname = aa.AccountName,
   cc.donorstatus = aa.status, 
   cc.DonorPriorityPoints = aa.AdjustedPP,
   cc.DonorPPRank = aa.PPRank,
   cc.TMFInd = aa.DonorInd,
  -- cc.TicketingInd=  aa.TicketingInd,
   cc.TMFSetupDate = aa.SetupDate --,
 --  cc.TicketSetupDate = aa.initdate
   ;
   
  -- select email , count(*) from advcontact where email in (select email from  amy.athContacts)  group by email
 --  select email from 
  
   --Step 5: update address if donor
merge  amy.athContacts a using 
(select adnumber, ca.* from   advcontact c ,  amy.advcontactaddresses_unique_primary_vw ca where c.contactid = ca.contactid
-- and c.email not in (select email from  amy.athContacts group by email having count(*) > 1)
 ) b
on a.donornumber = b.adnumber and street1 is null   
when matched 
then update  -- set a.promotion_cnt =  isnull(a.promotion_cnt,0) +1,
  set    a.street1= b.address1,
      a.street2 = b.address1 ,
      a.city = b.city  ,
      a.state  =  b.state ,
      a.zip   =   b.zip
      ;

         --step 6: update ticketing only contacts
      
    merge athcontacts cc 
    using (
       select  --v.email, u.email, c.email,
    distinct
   min( v.accountnumber) accountnumber ,  min(v.lastname)lastname, min(v.firstname) firstname, min(v.phone1) phone1, min(v.email) email, min(v.zip) zip, min(v.state) state, min(v.city) city, min( v.address1) address1, min(v.address2) ADDRESS2, 
   u.id ,
  --  c.ADNumber, c.Status, c.AccountName, c.FirstName, c.LastName, c.Email , 1 DonorInd,
  1 TicketingInd,
  --  c.AdjustedPP, c.LifetimeGiving, c.PPRank, c.SetupDate,
 min( v.initdate) initdate
   --   u.*
    from ods.VTXcustomers  v join  amy.athContacts u on v.email = u.email
   -- left join advcontact c on cast(c.adnumber as varchar) = v.accountnumber
    where  DonorNumber is null and ticketaccountnumber is null  and v.lastname <>  'HOUSE ACCOUNT'
    group by u.id ) aa 
    on aa.id = cc.id and cc.ticketaccountnumber is null and cc.donornumber is null
when matched 
then update
 set cc.ticketaccountnumber =  aa.accountnumber , 
      cc.TicketingInd=  aa.TicketingInd,
   cc.TicketSetupDate = aa.initdate;
   


 /* merge athContacts ac using (
select  
 a.id,  a.email,  a.fsbidcnt, a.firstname, a.FSInd ,
--a.seatcount,
fs.first_name,
fs.last_name, fs.birthdate, -- fs.email,
fs.account_created_datetime, fs.flashseats
from athContacts a
--left join advcontact c on a.email = c.email
 join (select 1 flashseats, fsa.*, e.email from ods.FS_accounts fsa join ods.fs_emails   e on fsa.account_id = e.account_id) fs on a.email = fs.email
left join (select account_id,
count(*) fsbidcnt, 
sum(case when bid_action='ACCEPT_ASK' then 1 else 0 end) fsbidwins, 
avg(case when bid_action='ACCEPT_ASK' then bid_price_per_ticket else null end) bidperticket, 
avg(case when bid_action='ACCEPT_ASK' then bid_ticket_quantity  else null end) bidticketcnt from  ods.FS_bids group by account_id) fsbids on fs.account_id = fsbids.account_id
left join (select account_id, count(*) fslistingcnt from  ods.FS_listings group by account_id) fslist on fs.account_id = fslist.account_id
where (fs.flashseats is not null) and (a.FSInd  is  null ) and fs.email not in (select fsa.email from   ods.fs_emails fsa group by fsa.email having count(*) > 1)
    --  and a.email not in (select email from  athContacts group by email having count(*) > 1)
) b
on ac.id = b.id
when matched 
then update
  set ac.fsbidcnt = isnull(ac.fsbidcnt ,b.fsbidcnt) ,
 -- ac.[FSBidWins] = isnull([FSBidWins],b.fsbidwins) ,
  ac.fsind = isnull(ac.fsind ,b.flashseats), 
  ac.firstname= isnull(ac.firstname ,b.first_name),
   ac.lastname= isnull(ac.lastname,b.last_name),
   fsbirthdate= isnull(ac.fsbirthdate ,b.birthdate)
   ;
*/
merge athcontacts c  using (    
 select accountnumber, min( case when tixeventlookupid like 'F%Season' and  tixeventlookupid like 'F18-Season' then 1 when tixeventlookupid like 'F%Season' then  1 else null end ) FB ,
 min( case when tixeventlookupid like 'BS%Season' and  tixeventlookupid like 'BS18-Season' then 1 when tixeventlookupid like 'BS%Season' then 1 else null end ) BSB ,
   min( case when tixeventlookupid like  'B%-MB' and  tixeventlookupid like 'B17-MB' then 1 when tixeventlookupid like  'B%-MB' then  1 else null end ) MB ,
     min( case when tixeventlookupid like 'B%-WB' and  tixeventlookupid like 'B17-WB' then 1  when  tixeventlookupid like 'B%-WB' then 1 else null end ) WB ,
       min( case when tixeventlookupid like 'SB%Season' and  tixeventlookupid like 'SB18-Season' then 1 when tixeventlookupid like 'SB%Season' then 1 else null end ) SB ,
           min( case when tixeventlookupid like 'TN%Season' and  tixeventlookupid like 'TN17-Season' then 1 when tixeventlookupid like 'TN%Season' then 1 else null end ) TN,
    min( case when tixeventlookupid like 'TR%Season' and  tixeventlookupid like 'TR18-Season' then 1 when tixeventlookupid like 'TR%Season' then 1 else null end ) TK ,
  min( case when tixeventlookupid like 'SC%Season' and  tixeventlookupid like 'SC18-Season' then 1 when tixeventlookupid like 'SC%Season' then  1 else null end ) SC ,   
  min( case when tixeventlookupid like 'VB%Season' and  tixeventlookupid like 'VB17-Season' then 1 when tixeventlookupid like 'VB%Season'  then 1 else null end ) VB 
 from seatdetail_individual_history where -- tixeventlookupid like 'F%Season' and 
 cancel_ind is not null
 group by  accountnumber
) b
on  c.DonorNumber = b.accountnumber
when matched then update
 set c.FB = b.FB, c.BSB = b.BSB , c.MB = b.MB ,c.WB = b.WB ,
 c.SB = b.SB , c.TN = b.TN, c.TK = b.TK ,  c.SC = b.SC  ,    c.VB  = b.VB 
 ;
 
 merge athcontacts c  using (    
 select g.email, g.min_account_id account_id, fa1.account_created_datetime, 
 fa1.birthdate, replace(replace(replace(replace(isnull(fa1.mobile_phone_number,fa1.home_phone_number),' ',''),'(',''),')',''),'-','') mobile_phone_number 
 from ods.FS_accounts fa1,
  (select fe.email, min(fa.account_id) min_account_id 
  from  ods.FS_accounts  fa, ods.FS_emails fe where fa.account_id = fe.account_id and mobile_phone_number is not null
  group by  fe.email) g where fa1.account_id = g.min_account_id
) b
on b.email = c.email
when matched then update
 set c.fsaccount = b.account_id,
 c.fsind = 1,
 c.fssetupdate = isnull(c.fssetupdate,account_created_datetime),
 c.fsBirthDate = isnull(c.fsBirthDate,birthdate),
 c.phone = isnull(c.phone, b.mobile_phone_number)
 ;

merge athcontacts c  using (     select  athc.id,  adnumber, replace(replace(replace(replace(isnull(mobile,phhome),' ',''),'(',''),')',''),'-','') phone 
       from advcontact  advc, athContacts athc 
       where adnumber = donornumber and athc.phone is  null and athc.donornumber is not null and  isnull(replace(replace(replace(replace(isnull(mobile,phhome),' ',''),'(',''),')',''),'-',''),'') <> '' ) b
       on b.id= c.id
when matched 
then update
 set c.phone = b.phone;
 
 --promotioncnt
  merge athcontacts c  using (  
select * from (
select c.id, c.email, isnull(promotion_cnt,0) promotion_cnt, count(i.id) cnt from athcontacts  c, athInteraction i where c.id = i.id
group by c.id, c.email,isnull(promotion_cnt,0)
) y where promotion_cnt <> cnt )b
on b.id = c.id
when matched 
then update
 set 
  c.promotion_cnt= b.cnt;
  
 
 update athcontacts set student_ind = 1 where id in (
select id from athcontacts where email in (select email from zz_tbl_student  where import_date <> '1/1/2000') or 
lastname+ ', ' + firstname in (select name from zz_tbl_student  where import_date <> '1/1/2000'))

 update athcontacts  set fullname = firstname + ' ' + lastname where fullname is null and firstname is not null and lastname is not null



end
GO
