/*
exec sp_SpecializedServiceSummary 6137, '11/1/2015', '11/30/2015'
*/


if OBJECT_ID('[sp_SpecializedServiceSummary]') is not null 
	drop procedure [dbo].[sp_SpecializedServiceSummary]
	
go

create procedure [dbo].[sp_SpecializedServiceSummary] (
	@ru	int,
	@startdate datetime, 
	@enddate datetime
)

as

with cte_events 
as
(
	select e.clientid 
		, c.lastname 
		, c.FirstName 
		, e.sac 
		, s.description 
		--, e.StandardFee 
		, case when convert(decimal(10,2), s.UOSFee) = 0 then e.StandardFee else s.UOSFee end 'StandardFee'
		, sum(e.ComputedFee) AS 'Total'
--		, sum( convert(decimal(10,2), 
--			round((e.ComputedFee / case when e.standardfee = 0 then 1 else e.standardfee end)/25, 2)*25)) AS 'Unit'
		, sum( convert(decimal(10,2), 
			round((e.ComputedFee / case 
				when convert(decimal(10,2), s.uosfee) = 0 then 
					case when e.StandardFee = 0 then 1.00
					else e.StandardFee
					end
				else s.UOSFee end)/25, 2)*25)) AS 'Unit'
	from Client.Events e
	 left join Client.client_record c
	 on c.clientid = e.clientid
	 left join SysFile.sac s
	on s.sac = e.sac
	where ru = @ru 
	 and eventdate between @startdate and @enddate
	and e.SAC > 0
	and e.ComputedFee > 0
	group by e.ClientID
		, c.lastname 
		, c.FirstName
		, e.SAC
		, s.description
		, case when convert(decimal(10,2), s.UOSFee) = 0 then e.StandardFee else s.UOSFee end
		--, s.uosfee
		--, e.StandardFee
)
select
	e.clientid 'Local Case Number'
	, e.LastName + ', ' + e.FirstName 'Name of Individual'
	, case when e.sac = 5052 then
		case when e.standardFee = 44.76 then 5053
		else e.SAC
		end
	else e.sac 
	end 'Service Code'
	, case when e.sac = 5052 then
		case when e.standardFee = 22.38 then 'Day Habilityation 1 - 2.9 Hours'
		else 'Day Habilitation 3 + Hours' 
		end
	  when e.SAC = 5051 then 'Behavioral Support'
	  when e.SAC = 5050 then 'Determination of Intellectual Disability Assessment'
	  when e.SAC = 5053 then 'Employment Assistance Per Hour'
	  when e.SAC = 5054 then 'Independent Living Skills Training Per Hour'
	  when e.SAC = 5055 then 'Supported Employment Per Hour'
	  when e.sac = 5056 then 'Non-HCS or TxHml Services Coordination Face-to-Face'
	else e.description 
	end 'Description of Service'
	, e.StandardFee 'Rate'
	, convert(decimal(10,2), 
		case when e.Total = e.unit * e.standardFee then e.total else e.unit * e.standardfee end) 'Total'
	, e.Unit
from cte_events e
GO


