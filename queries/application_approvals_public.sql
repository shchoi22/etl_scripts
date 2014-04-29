select 
  score
 ,decision
 ,replaced_by
 ,approvals.application_id
 ,applicants_applications.applicant_id
 ,underwriting_model_id
 ,created_at
 ,updated_at
 ,status
 ,tier
 ,amount
 ,move_in_fee
 ,deposit
 ,approved_for_unit
 ,poi as proof_of_income
 ,tier_reason
 ,amount_reason
 ,approved_for_unit_reason
 ,co_signer_reason
 ,deposit_reason
 ,move_in_fee_reason
 ,poi_reason
 
from approvals
left outer join applicants_applications on approvals.application_id = applicants_applications.application_id
where process_state = 'underwritten'
