select 
   lease_signings.start_time as lease_signing_time
  ,lease_signings.prospect_id
  ,buildings.name as building_name
  ,units.name as unit_name
  ,lease_signings.agent
  ,lease_signings.secondary_agent
  ,lease_signings.zone_office
  ,lease_signings.showable_state as lease_signing_status
  ,lease_signings.created_at
  ,lease_signings.updated_at
  ,lease_signings.showable_canceled_by as cancelled_party
  ,lease_signings.showable_canceled_reason as cancel_reason
  ,created_by.user as created_by
  ,updated_by.user as updated_by
from lease_signings
left outer join units on units.id = lease_signings.unit_id
left outer join buildings on buildings.id = lease_signings.building_id
left outer join activities as created_by on lease_signings.id = created_by.record_id
                and created_by.record_type = 'leasesigning'
                and created_by.action = 'created_leasesigning'
left outer join activities as updated_by on lease_signings.id = updated_by.record_id
                and updated_by.record_type = 'leasesigning'
                and updated_by.action = 'updated_leasesigning'
