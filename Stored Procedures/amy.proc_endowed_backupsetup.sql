SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [amy].[proc_endowed_backupsetup] (@endowedsetupid int)
as
begin
insert into  EndowedSetupHistory 
(EndowedSetupID, ADNumber, ActiveStatus, SeasonQty, RoadGameQty, PriceCode, AccountName, EstablishedYear, EndDate, EndDateInitialLength, Status, 
Endowment, Terms, Beneficiaries, SpouseName, Notes, CreateDate, CreateUser, UpdateDate, UpdateUser, pastadnumber, ActualQtyUsed, EndowedCreditTotal, EndowmentNumber,
HistoryCreateDate)
select EndowedSetupID, ADNumber, ActiveStatus, SeasonQty, RoadGameQty, PriceCode, AccountName, EstablishedYear, EndDate, EndDateInitialLength, Status, 
Endowment, Terms, Beneficiaries, SpouseName, Notes, CreateDate, CreateUser, UpdateDate, UpdateUser, pastadnumber, ActualQtyUsed, EndowedCreditTotal, EndowmentNumber,
getdate()
from EndowedSetup where EndowedSetupID = @endowedsetupid 

 end
GO
