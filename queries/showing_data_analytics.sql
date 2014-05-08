select 
  cast(customer_id as int) as customer_id
  ,case when application_id ='' then null else cast(cast(application_id as numeric) as int) end as application_id
  ,case when first_app_submitted_at ='' then null else cast(first_app_submitted_at as timestamp) end as first_app_submitted_at
  ,cast(showing_date as timestamp) as showing_date
  ,showing_status
  ,leasing_agent
  ,building_name
  ,unit_name
  ,showable_canceled_by
  ,showable_canceled_reason
  ,applicant_type
  ,app_in_before_showing
  ,received_app_at_showing
  ,received_app_within_8_hrs
  ,last_showing
  ,last_showing_to_convert
  
from pcore_showing_data
