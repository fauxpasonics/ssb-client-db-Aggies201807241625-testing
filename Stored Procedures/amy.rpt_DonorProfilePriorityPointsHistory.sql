SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [amy].[rpt_DonorProfilePriorityPointsHistory]  @ADNumber int as
    Declare @contactid int
   
   Begin
   
    set @contactid =( select contactid from advcontact where adnumber = @ADNumber)
  
     select  hp.entrydate, hp.rank, hp.cash_basis_ppts + hp.linked_ppts - hp.linked_ppts_given_up points, cs.points_values,  updatedate from  ADVHistoricalPriorityPoints Hp
     left join amy.ADVContactPointsSummaryHistory CS on  hp.contactid = cs.contactid and Hp.EntryDate = cs.entrydate and hp.entrydate >= getdate()-365 
     where hp.contactid = @contactid 
     order by hp.entrydate desc 
     

  
  end
GO
