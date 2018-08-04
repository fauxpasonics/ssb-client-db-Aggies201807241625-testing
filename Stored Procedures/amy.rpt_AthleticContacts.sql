SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--exec rpt_AthleticContacts 0,null,null,null, null
CREATE procedure [amy].[rpt_AthleticContacts] ( @STATUS bit = 0, @CREATIONSOURCE nvarchar(MAX)= null, @SOURCEPROMO nvarchar(MAX)= null, @CONTACTTYPE nvarchar(MAX)= null, 
@transtype nvarchar(50) = 'START')
as

declare @querysql nvarchar(MAX)
Declare @ADNUMBERLISTCLEAN  nvarchar(MAX)


set @querysql = 'select * from (
select firstname, lastname, email, create_date, creation_source, promotion_cnt, 
 promo_opt_in  promo_opt_in_ind,
case when  promo_opt_in = 1 then ''X'' else null end promo_opt_in,
case when  DonorInterest = 1 then ''X'' else null end DonorInterest, 
case when  TicketsInterest = 1 then ''X'' else null end TicketsInterest,
case when  KidsInterest = 1 then ''X'' else null end KidsInterest,
case when  MilitaryInterest = 1 then ''X'' else null end MilitaryInterest, 
case when  tmfind = 1 then ''X'' else null end tmfind,
case when  fsind = 1 then ''X'' else null end fsind,
case when  ticketingind = 1 then ''X'' else null end ticketingind,
case when  onlineauctionind = 1 then ''X'' else null end onlineauctionind,  
 case when isnull(tmfind,0)=1   and DonorStatus in (''Active'',''Lifetime'') then ''Donor''
   when isnull(tmfind,0)=1    and DonorStatus  not in (''Active'',''Lifetime'') then ''Inactive Donor''
   when isnull(tmfind,0)=0   and ticketingind =1   then ''Tickets Only''
   when isnull(tmfind,0)=0   and  isnull(ticketingind,0)=0 and isnull(fsind,0) = 1   then ''Flash Seats''
   else ''Athletics Source''  
 end ContactType  ,
 street1, street2, city, state, zip, country,
 macid,auction_id, AuctionUserName, AuctionLastLogin, AuctionTotalBids, AuctionCnt, 
 TMFSetupDate, FSSetupDate, TicketSetupDate, OnlineAuctionSetupDate, 
 DonorNumber, DonorAccountName, DonorStatus, DonorLifetimeGiving, DonorPriorityPoints, DonorPPRank, 
 FSBirthDate, FSBidCnt, FSBidWins, FSListingCnt,
 TicketAccountNumber,FB,BSB,MB,WB,SB,TN,TK,SC,VB,
 hh.id contactid, hh.id
from amy.athcontacts hh  ) x '

  set @querysql = @querysql  + ' where 1=1'
  
     if (isnull(@TRANSTYPE, '') ='START')
 set @querysql = @querysql  + 'and  1 =2 '


 if isnull( @STATUS, 0) = 1
 set @querysql = @querysql  + ' and isnull( promo_opt_in_ind ,0)  = 1 '
 
 if (@CREATIONSOURCE  is not null and @CREATIONSOURCE <> '') 
 set @querysql = @querysql  +  ' and  '','+ @CREATIONSOURCE +','' '+' like ' + '   ''%,'' +creation_source+'',%'' '  
 
 if (@SOURCEPROMO  is not null and @SOURCEPROMO <> '') 
 set @querysql = @querysql  +  ' and id in
(select distinct i.id from amy.athInteraction i , amy.athContactTypes  t where i.contacttypeid  = t.id and  '','+@SOURCEPROMO  +','' = '',''+descr+'','')   '

 if (@CONTACTTYPE  is not null and @CONTACTTYPE <> '') 
 set @querysql = @querysql  +  ' and    '','+@CONTACTTYPE  +','' like  ''%,''+ contacttype +'',%''  '  

--select @querysql
execute( @querysql)
GO
