SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [amy].[rpt_CreationSource] as
select distinct creation_source,  T.contact_start_date from athcontacts C, athContactTypes T  where c.contacttypeid=  T.id
order by T.contact_start_date
GO
