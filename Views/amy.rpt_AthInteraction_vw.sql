SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  view  [amy].[rpt_AthInteraction_vw] as
select
--cast(ConvertedDonor as decimal)/cast(TTL as decimal)*100 ConvertedDonorper, 
-- cast(preDonor as decimal)/ cast(TTL as decimal)*100  preDonorper, 
--  cast(NotDonorsFS as decimal)/ cast(TTL as decimal)*100  NotDonorbutFSper,
--  cast(AuctionOnly as decimal)/ cast(TTL as decimal)*100  AuctionOnlyper,
 r.* from (
select  count(*)  TTL, sum( case when isnull(prs_created,'1/1/9999') < tmfsetupdate then 1 else 0 end ) ConvertedDonor,
sum( case when isnull(prs_created,'1/1/9999')> tmfsetupdate then 1 else 0 end) preDonor, 
sum( case when adnumber is null and flashseats = 1 then 1 else 0 end ) NotDonorsFS,
sum( case when adnumber is null and isnull(flashseats,0) = 0  and creation_source = 'JerseyPromo' then 1 else 0 end ) JerseyPromo,
sum( case when adnumber is null and isnull(flashseats,0) = 0  and creation_source = 'HelmetPromo' then 1 else 0 end ) HelmetPromo,
sum( case when adnumber is null and isnull(flashseats,0) = 0  and creation_source = 'ArkansasPromo' then 1 else 0 end ) ArkansasPromo,
sum( case when adnumber is null and isnull(flashseats,0) = 0  and creation_source = 'AthShop' then 1 else 0 end ) AthShop,
sum( case when adnumber is null and isnull(flashseats,0) = 0  and creation_source = 'OnlineAuction' then 1 else 0 end ) OnlineAuction,
sum( case when adnumber is null and isnull(flashseats,0) = 0  and creation_source = 'BB_1006' then 1 else 0 end ) BB_1006
from amy.zzathAllContacts_old ) R
GO
