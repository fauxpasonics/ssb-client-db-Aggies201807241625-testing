SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [amy].[veritix_events] as 
select tixeventid, tixeventlookupid, tixeventtitleshort,  tixeventinitdate, 
isnull(seasonparentname, seasonparentnamenew) Yearcategory,
seasonchildname category ,
SubCategory,
ltrim(isnull(  seasonparentname, seasonparentnamenew)  + case when seasonchildname is not null then  ' / ' +   seasonchildname else '' end ) CategoryAlT,
ltrim(isnull(eventcatparentname,eventcatparentnamenew)  + case when eventcatchildname is not null then  ' / ' +   eventcatchildname else '' end ) SubCategoryALT  , 
isnull(seasonparentname, seasonparentnamenew) seasonparentname,
 seasonchildname,
isnull(eventcatparentname,eventcatparentnamenew) eventcatparentname, eventcatchildname ,
ltrim(isnull(  seasonparentname, seasonparentnamenew)  + case when seasonchildname is not null then  ' / ' +   seasonchildname else '' end ) SeasonCategory,
ltrim(isnull(eventcatparentname,eventcatparentnamenew) + case when eventcatchildname is not null then  ' / ' +   eventcatchildname else '' end ) EventCategory   
  from (
select e.tixeventid, tixeventlookupid, tixeventtitleshort,  tixeventinitdate, 
seasonparent.categoryname cat1parent,
seasonchild.categoryname cat1name ,
case when tixeventlookupid like '%-Season' then 'Season'
when tixeventlookupid like '%-PK'  and tixeventlookupid not like '%Base%' and tixeventlookupid not like '%-%-%' then 'SeasonParking' 
when tixeventlookupid like '%-PK'  then 'Parking' 
when tixeventtitleshort like '%Donation%' then 'Donations' else  eventcatchild.categoryname end SubCategory,
 eventcatparent.categoryname cat2parent,
 eventcatchild.categoryname cat2name, 
 seasonparent.categoryname  seasonparentname,
seasonchild.categoryname seasonchildname,seasonchild.parentname seasonparentnamenew,
  eventcatparent.categoryname   eventcatparentname,
  eventcatchild.categoryname   eventcatchildname  , eventcatchild.parentname  eventcatparentnamenew
from ods.VTXtixevents e
     left join (select  ce.tixeventid, catparent.categoryname, catparent.categoryid  
                    from ods.VTXeventcategoryrelation  ce  
                         join ods.VTXcategory catparent  on  catparent.categoryid = ce.categoryid 
                             and catparent.parentid is null and catparent.categorytypeid = 1     ) seasonparent on e.tixeventid = seasonparent.tixeventid 
      left  join (select  ce.tixeventid, catchild.categoryname,  catchild.categoryid  , catchild.parentid, parent.categoryname parentname
                    from ods.VTXeventcategoryrelation  ce  
                         join ods.VTXcategory catchild   on  catchild.categoryid = ce.categoryid 
                             and catchild.parentid is not null and catchild.categorytypeid = 1  
                           join ods.VTXcategory parent    on catchild.parentid  = parent.categoryid    ) seasonchild 
                              on e.tixeventid = seasonchild.tixeventid   --and seasonchild.parentid  =   seasonparent.categoryid  
      left join (select  ce.tixeventid, catparent.categoryname, catparent.categoryid  
                    from ods.VTXeventcategoryrelation  ce  
                         join ods.VTXcategory catparent  on  catparent.categoryid = ce.categoryid 
                             and catparent.parentid is null and catparent.categorytypeid = 2     ) eventcatparent on e.tixeventid = eventcatparent.tixeventid 
      left  join (select  ce.tixeventid, catchild.categoryname,  catchild.categoryid  , catchild.parentid, parent.categoryname parentname
                    from ods.VTXeventcategoryrelation  ce  
                         join ods.VTXcategory catchild   on  catchild.categoryid = ce.categoryid 
                             and catchild.parentid is not null and catchild.categorytypeid = 2  
                           join ods.VTXcategory parent    on catchild.parentid  = parent.categoryid
                             ) eventcatchild 
                              on e.tixeventid = eventcatchild.tixeventid      
   where  
   isnull(seasonparent.categoryname,seasonchild.parentname)  <> 'Test' and tixeventlookupid not like 'Test%'  
  ) rt
  where  isnull(seasonparentname, seasonparentnamenew) not in ('Basketball','Track','Tennis','KFR')
GO
