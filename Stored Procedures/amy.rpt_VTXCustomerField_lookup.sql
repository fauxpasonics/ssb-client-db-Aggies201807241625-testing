SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create  PROCEDURE [amy].[rpt_VTXCustomerField_lookup]  (@customerfieldid INT =0  ) AS
select  NAME customerfieldname from  ods.VTXcustomerfields cf where ID =@customerfieldid
GO
