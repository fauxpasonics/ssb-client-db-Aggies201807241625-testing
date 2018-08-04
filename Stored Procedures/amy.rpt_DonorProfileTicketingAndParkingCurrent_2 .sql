SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [amy].[rpt_DonorProfileTicketingAndParkingCurrent_2 ]
@ADNumber nvarchar(200)
AS
select 
accountnumber, categoryname, tixeventlookupid, tixeventtitleshort, qty, year, seatblock, seatpricecode, seatsection, seatrow, seatseat, paid, sent
from seatdetail_flat where  year = year(getdate()) and accountnumber = @ADNumber
GO
