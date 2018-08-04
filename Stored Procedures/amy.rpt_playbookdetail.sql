SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  procedure  [amy].[rpt_playbookdetail] (@sporttype varchar(10),@ticketyear varchar(4),@SectionNum varchar(20) null, @Rows varchar(20) null, @PriceCodeName varchar(20) null ) as
select PriceGROUPName PriceGroupName, seatareaname,	sporttype,	ticketyear,	case when pricecodecode = pricecodename then PriceCodeName else pricecodecode + ' - ' + pricecodename end PriceCodeName	,SectionNum	,Rows,	Annual,	Annualseatallocation,	
CAP Capital,	Capitalseatallocation, Ticket_Amount, seatareacode
 from playbookpricegroupsection
where sporttype = @sporttype and ticketyear =@ticketyear and seatareaname not like '%Suite%'
and (@SectionNum is null or (@SectionNum is not null and SectionNum like @SectionNum))
and (@PriceCodeName is null or (@PriceCodeName is not null and PriceCodeName like @PriceCodeName))
and (@Rows is null or (@Rows is not null and rOWS like '%;'+@Rows + ';%') or Rows is null )
GO
