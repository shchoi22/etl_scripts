select
   cast(leaseidnumber as int) as lease_id
  ,leasename as lease_name
  ,building
  ,primarycontactfirstname as first_name
  ,primarycontactlastname as last_name
  ,status
  ,reasonforleaving as reason_for_leaving
  ,publicassistanceprogram as subsidy_type
  ,cast(createdtime as timestamp) as created_at
  ,startdate as start_date
  ,enddate as end_date
  ,moveindate as move_in_date
  ,vacateddate as vacated_date
  ,scheduledmoveoutdate as scheduled_moveout_date
  ,unit
from pw_lease
