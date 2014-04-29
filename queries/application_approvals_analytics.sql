select 
  case when score ='' then null else cast(score as numeric) end as score
  ,decision
  ,case when replaced_by = '' then null else cast(cast(replaced_by as numeric) as int) end as replaced_by
  ,cast(application_id as int) as application_id
  ,case when applicant_id ='' then null else cast(cast(applicant_id as numeric) as int) end as applicant_id
  ,cast(underwriting_model_id as int) as underwriting_model_id
  ,cast(created_at as timestamp) as created_at
  ,cast(updated_at as timestamp) as updated_at
  ,status
  ,case when amount ='' then null else cast(amount as numeric) end as max_rent
  ,case when move_in_fee ='' then null else cast(move_in_fee as numeric) end as move_in_fee
  ,case when deposit ='' then null else cast(deposit as numeric) end as deposit
  ,approved_for_unit
  ,proof_of_income
  ,tier_reason
  ,amount_reason
  ,approved_for_unit_reason
  ,co_signer_reason
  ,deposit_reason
  ,move_in_fee_reason
  ,poi_reason
from application_approvals 
