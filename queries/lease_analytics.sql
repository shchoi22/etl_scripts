with pw_lease as (select pw_lease.*
			,replace(replace(replace(replace(pw_lease.primarycontacthomephone,' ',''),'-',''),'(',''),')','') as home_phone
			,replace(replace(replace(replace(pw_lease.primarycontactmobile,' ',''),'-',''),'(',''),')','') as mobile_phone
			,replace(replace(replace(replace(pw_lease.primarycontactworkphone,' ',''),'-',''),'(',''),')','') as work_phone
			,replace(replace(replace(replace(pw_lease.primarycontacthomephone,' ',''),'-',''),'(',''),')','') ||
				replace(replace(replace(replace(pw_lease.primarycontactmobile,' ',''),'-',''),'(',''),')','') ||
				replace(replace(replace(replace(pw_lease.primarycontactworkphone,' ',''),'-',''),'(',''),')','')  as combined_phone
			,initcap(lower(pw_lease.primarycontactfirstname)) as first_name
			,initcap(lower(replace(pw_lease.primarycontactlastname,'-',' '))) as last_name
			,replace(replace(replace(replace(pw_lease.primarycontacthomephone,' ',''),'-',''),'(',''),')','') ||
				replace(replace(replace(replace(pw_lease.primarycontactmobile,' ',''),'-',''),'(',''),')','') ||
				replace(replace(replace(replace(pw_lease.primarycontactworkphone,' ',''),'-',''),'(',''),')','')||lower(pw_lease.primarycontactfirstname)||lower(pw_lease.primarycontactlastname)  as combined_contact
		from pw_lease)
select
   pw_lease.leasename as lease_name
   ,pw_lease.building
   ,pw_lease.monthlyrent as monthly_rent
   ,pw_lease.rentdueday as rent_due_day
   ,pw_lease.publicassistanceprogram as subsidy_type
   ,pw_lease.s8stage as s8_stage
   ,pw_lease.first_name
   ,pw_lease.last_name
   ,pw_lease.home_phone
   ,pw_lease.work_phone
   ,pw_lease.mobile_phone
   ,pw_lease.primarycontactemail as email
   ,pw_lease.collectioncommunicationstatus as collection_communication_status
   ,pw_lease.brastatus as bra_status
   ,pw_lease.backofficecollectionevfiledate as back_office_collection_ev_file_date
   ,pw_lease.unit
   ,pw_lease.pangealoyaltystatus as pangea_loyalty_status
   ,pw_lease.backofficecollectionstatus as back_office_collection_status
   ,cast(pw_lease.createdtime as timestamp) as created_at
   ,pw_lease.mtmfee as mtm_fee
   ,pw_lease.nevermovedinreason as never_moved_in_reason
   ,pw_lease.nevermovedinsubcategory as never_moved_in_subcategory
   ,pw_lease.ofpstaydate as ofp_stay_date
   ,pw_lease.noticegivendate as notice_given_date
   ,pw_lease.papstage as pap_stage
   ,pw_lease.status
   ,pw_lease.reasonforleavingsubcategory as reason_for_leaving_subcategory
 /*
   ,pw_lease.s8checklistnotes as s8_checklist_notes
   ,pw_lease.s8initialinspectionpassdate as s8_initial_inspection_pass_date
   ,pw_lease.s8confirmedinspectiondate as s8_confirmed_inspection_date
   ,pw_lease.s8childrenunder6 as s8_children_under_6
   ,pw_lease.s8datehapsentbacktochadate as s8_date_hap_sent_back_to_cha_date
   ,pw_lease.s8enddate as s8_end_date
   ,pw_lease.s8hapcontractreceiveddate as s8_hap_contract_received_date
   ,pw_lease.s8movingpapersreciept as s8_moving_papers_reciept
   ,pw_lease.s8reasonfornotconverting as s8_reason_for_not_converting
*/
   ,pw_lease.startdate as start_date
   ,pw_lease.moveinitemchecklist as move_in_item_checklist
   ,pw_lease.moveoutcompliancedate as move_out_compliance_date
   ,pw_lease.brasigningdate as bra_signing_date
   ,pw_lease.collectioncommunicationfudate as collection_communication_fu_date
   ,cast(pw_lease.leaseidnumber as int) as lease_id
   ,pw_lease.enddate as end_date
   ,pw_lease.balance
   ,pw_lease.moveindate as move_in_date
   ,pw_lease.vacateddate as vacated_date
   ,pw_lease.scheduledmoveoutdate as scheduled_moveout_date
   ,pw_lease.reasonforleaving as reason_for_leaving
  ,internal_move.first_converted
  ,case when pw_lease.moveindate <= greatest(buildings.asset_acquisition_date,buildings.management_takeover_date) then 'Inherited' else 'Organic' end as tenant_acquisition_type
  ,case when internal_move.combined_contact is null then 'Original' else 'Internal Move' end as internal_move
from pw_lease
left outer join analytics.buildings on pw_lease.building = buildings.building
left outer join (select combined_contact
		        ,min(cast(createdtime as timestamp)) as first_converted
			from pw_lease
			group by combined_contact) as internal_move
		on pw_lease.combined_contact=internal_move.combined_contact
			and cast(pw_lease.createdtime as timestamp) != internal_move.first_converted
