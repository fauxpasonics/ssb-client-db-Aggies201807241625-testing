SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE view [amy].[rpt_AthContactType_vw]  as
 select TTL,  cast(auction as decimal)/cast(ttl as decimal) auction,
 cast(TMF as decimal)/cast(ttl as decimal)  TMF,
cast( FlashSeats as decimal)/cast(ttl as decimal)  FlashSeats,
cast(fsbidcnt as decimal)/cast(ttl as decimal) fsbidcnt,
cast( SeasonTickets as decimal)/cast(ttl as decimal) SeasonTickets,
 ttl ttlcnt, tmf tmfcnt, flashseats flashseatscnt,
 fsbidcnt flashseatbidscnt,
 SeasonTickets seasonticketscnt from (
select  count(*)  TTL, count(*) auction, sum( case when adnumber is not null then 1 else 0 end ) TMF,
sum( case when flashseats = 1 then 1 else 0 end ) FlashSeats,
sum( case when fsbidcnt >= 1 then 1 else 0 end ) fsbidcnt,
sum( case when isnull(seatcount,0) >=1 then 1 else 0 end ) SeasonTickets
from amy.zzathAllContacts_old y ) t
GO
