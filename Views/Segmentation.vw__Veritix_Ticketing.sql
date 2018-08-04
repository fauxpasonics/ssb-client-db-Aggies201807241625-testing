SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Segmentation].[vw__Veritix_Ticketing] 

AS

SELECT ssbid.SSB_CRMSYSTEM_CONTACT_ID
	   ,CAST(orderGroup.customerID AS INT) customerID
	   ,DATEPART(yyyy,events.tixeventstartdate) eventYear
	   ,CAST(events.tixeventstartdate AS DATE) eventDate
	   ,events.tixeventlookupid EventLookupID
	   ,events.tixeventtitleshort EventName
	   ,priceCode.tixsyspricecodedesc PriceCodeDesc
	   ,PriceType.tixsyspricecodetypedesc PriceTypeDesc
	   ,COUNT(DISTINCT seat.tixseatdesc ) AS QTY
	   ,SUM(Payments.paymentamount) AS PAIDTOTAL
	   ,SUM(PriceChart.tixevtznpricecharged) AS ORDTOTAL
FROM ods.VTXtixeventzoneseats seat	
	JOIN ods.VTXordergroups orderGroup (NOLOCK) ON orderGroup.ETL_IsDeleted = 0 
												   AND seat.tixseatordergroupid = CAST(orderGroup.ordergroup AS NVARCHAR(200))
	JOIN dbo.dimcustomerssbid ssbid (NOLOCK) ON ssbid.SSID = orderGroup.customerid
												AND ssbid.SourceSystem = 'veritix'
												AND ssbid.SSB_CRMSYSTEM_PRIMARY_FLAG = 1
	LEFT JOIN ods.VTXtixevents events (NOLOCK) ON events.ETL_IsDeleted = 0 
												  AND CAST(events.tixeventid AS NVARCHAR(200)) = seat.tixeventid
	LEFT JOIN ods.VTXtixsyspricecodes priceCode (NOLOCK) ON priceCode.ETL_IsDeleted = 0 
															AND seat.tixseatpricecode = CAST(priceCode.tixsyspricecodecode AS NVARCHAR(200))
	LEFT JOIN ods.VTXtixsyspricecodetypes PriceType (NOLOCK) ON PriceType.ETL_IsDeleted = 0 
																AND priceCode.tixsyspricecodetype = PriceType.tixsyspricecodetype 
	LEFT JOIN ods.VTXtixeventzoneseatgroups SeatGroup (NOLOCK) ON SeatGroup.ETL_IsDeleted = 0 
																  AND SeatGroup.tixeventid = seat.tixeventid
																  AND SeatGroup.tixeventzoneid = seat.tixeventzoneid
																  AND SeatGroup.tixseatgroupid = seat.tixseatgroupid
	--LEFT JOIN [ods].[VTXtixeventzoneseatgroups] SeatSection (NOLOCK) ON SeatSection.ETL_IsDeleted = 0 
	--																	AND SeatRow.tixseatgroupparentgroup = SeatSection.tixseatgroupid 
	--																	AND Seat.tixeventid = SeatSection.tixeventid 
	--																	AND Seat.tixeventzoneid = SeatSection.tixeventzoneid
	LEFT JOIN ods.VTXtixsyspricelevels PriceLevel (NOLOCK) ON Pricelevel.ETL_IsDeleted = 0 
															  AND PriceLevel.tixsyspricelevelcode = seat.tixseatpricecode
	LEFT JOIN ods.VTXtixeventzonepricechart PriceChart ON PriceChart.tixeventid = seat.tixeventid
														  AND PriceChart.tixeventzoneid = seat.tixeventzoneid
														  AND PriceChart.tixevtznpricelevelcode = SeatGroup.tixseatgrouppricelevel
														  AND PriceChart.tixevtznpricecodecode = priceCode.tixsyspricecodecode
	LEFT JOIN ods.VTXpayments Payments ON paymentprocessorresponsecode = 'SUCCESS'
										  AND Payments.ordergroupid = orderGroup.ordergroup
										  AND payments.customerid = orderGroup.customerid
WHERE 1=1									    
	  AND tixseatsold = 1
	  AND events.tixeventid = 3477
	  --AND orderGroup.customerid = '3689211'
GROUP BY ssbid.SSB_CRMSYSTEM_CONTACT_ID
	     ,CAST(orderGroup.customerID AS INT) 
	     ,DATEPART(yyyy,events.tixeventstartdate)
	     ,CAST(events.tixeventstartdate AS DATE) 
	     ,events.tixeventlookupid
	     ,events.tixeventtitleshort 
	     ,priceCode.tixsyspricecodedesc 
	     ,PriceType.tixsyspricecodetypedesc 
	     ,PriceLevel.tixsyspriceleveldesc
GO
