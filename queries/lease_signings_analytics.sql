select 
   cast(lease_signing_time as timestamp) as lease_signing_time
  ,cast(prospect_id as int) as prospect_id
  ,building_name
  ,unit_name
  ,agent
  ,secondary_agent
  ,zone_office
  ,lease_signing_status
  ,cast(created_at as timestamp) as created_at
  ,cast(updated_at as timestamp) as updated_at
  ,cancelled_party
  ,cancel_reason
  ,created_by
  ,updated_by

from lease_signings