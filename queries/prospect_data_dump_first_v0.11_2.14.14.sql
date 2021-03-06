﻿set search_path = pangea_api;
--explain
with customers_clean as
(select
   trim(lower(replace(replace(replace(customers.first_name,'-',' '),';',''),'/t',''))) as first_name_clean
  ,trim(lower(replace(replace(replace(customers.last_name,'-',' '),';',''),'/t',''))) as last_name_clean
  ,replace(replace(replace(replace(customers.home_phone,' ',''),'-',''),'(',''),')','') as home_phone_clean
  ,replace(replace(replace(replace(customers.mobile_phone,' ',''),'-',''),'(',''),')','') as mobile_phone_clean
  ,replace(replace(replace(replace(customers.work_phone,' ',''),'-',''),'(',''),')','') as work_phone_clean
  ,(case when mobile_phone is null then '' else replace(replace(replace(replace(customers.mobile_phone,' ',''),'-',''),'(',''),')','') end)||
   (case when work_phone is null then '' else replace(replace(replace(replace(customers.work_phone,' ',''),'-',''),'(',''),')','') end)||
   (case when home_phone is null then '' else replace(replace(replace(replace(customers.home_phone,' ',''),'-',''),'(',''),')','') end) as combined
  ,customers.*
  ,master_lead.name as master_lead_provider
  ,sub_lead_details.name as sub_lead_provider
  ,desktop_mobile.name as desktop_or_mobile
 from customers
  left outer join (select customers_promos.customer_id, master_lead.name  -- master lead
                 from customers_promos
                 left outer join promos as master_lead on master_lead.id = customers_promos.promo_id
                                   and master_lead.promo_type = 'master lead'
                 where master_lead.id is not null) as master_lead on master_lead.customer_id = customers.id

 left outer join (select customers_promos.customer_id, max(customers_promos.promo_id) as promo_id --sub lead
                 from customers_promos
                 left outer join promos as sub_lead on sub_lead.id = customers_promos.promo_id
                                   and sub_lead.promo_type = 'marketing'
                 where sub_lead.id is not null
                 group by customers_promos.customer_id) as sub_lead on sub_lead.customer_id = customers.id
 left outer join (select customers_promos.customer_id, desktop_mobile.name
                 from customers_promos
                 left outer join promos as desktop_mobile on desktop_mobile.id = customers_promos.promo_id
                                   and desktop_mobile.promo_type = 'lead_source'
                 where desktop_mobile.id is not null) as desktop_mobile on desktop_mobile.customer_id = customers.id
 left outer join promos as sub_lead_details on sub_lead_details.id = sub_lead.promo_id
      where
      customers.first_name is not null
      and customers.first_name !=''
      and customers.last_name is not null
      and customers.last_name !=''
      and customers.created_at > '2013-01-01'
      and customers.id not in(select dups.id
                        from (select customers.id, row_number() over(partition by first_name_clean, last_name_clean, combined order by customers.created_at asc) as row
                              ,last_application.applicant_id as applicant_id
                             from (select trim(lower(replace(replace(customers.first_name,';',''),'/t',''))) as first_name_clean, trim(lower(replace(replace(customers.last_name,';',''),'/t',''))) as last_name_clean
                                    ,(case when mobile_phone is null then '' else mobile_phone end)||(case when work_phone is null then '' else work_phone end)||(case when home_phone is null then '' else home_phone end) as combined
                                    ,customers.*
                                   from customers) as customers
                             left outer join applicants on customers.id = applicants.customer_id
                             left outer join (select applicant_id -- last application that was processed
						,max(applicants_applications.application_id) as application_id
						from applicants_applications
						left outer join (select max(approvals.application_id) as application_id from approvals group by application_id) as approvals on approvals.application_id = applicants_applications.application_id
						where approvals.application_id is not null
						group by applicant_id) as last_application on last_application.applicant_id = applicants.id
                             where
                               customers.first_name !=''
                               and customers.last_name !='') as dups
                         where
                           dups.row > 1
                           and dups.applicant_id is null order by dups.id))
--with prospect_data as (

select

 -- Customer Data --
  customers_clean.id
 ,customers_clean.pw_id as entity_id
 ,customers_clean.first_name_clean as first_name
 ,customers_clean.last_name_clean as last_name
 ,customers_clean.home_phone_clean as home_phone
 ,customers_clean.mobile_phone_clean as mobile_phone
 ,customers_clean.work_phone_clean as work_phone
 ,customers_clean.combined
 ,customers_clean.dob
 ,customers_clean.email
 ,customers_clean.created_at as created

 -- Prospect Data --
 ,prospects.id as prospect_id
 ,prospects.desired_beds as prospect_desired_beds
 ,prospects.desired_baths as prospect_desired_baths
 ,prospects.desired_location as prospect_desired_location
 ,prospects.number_of_occupants as prospect_number_of_occupants
 ,prospects.number_of_pets as prospect_number_of_pets
 ,prospects.move_in_date as prospect_move_in_date
 ,prospects.income_source as prospect_income_source
 ,prospects.evictions_within_twelve_months as prospect_evictions_within_twelve_months
 ,prospects.felonies_within_three_years as prospect_felonies_within_three_years
 ,prospects.monthly_income as prospect_monthly_income
 ,prospects.reason_not_converting as prospect_reason_not_converting
 ,prospects.subsidy_voucher as prospect_subsidy_voucher
 ,prospects.building_name as prospect_building_name
 ,prospects.unit_name as prospect_unit_name
 ,prospects.waitlisted_at as prospect_waitlisted_at
 ,prospects.desired_history as prospect_desired_history
 ,buildings.name as desired_building_name
 ,units.name as desired_unit_name
 ,units.target_rent
 ,customers_clean.master_lead_provider
 ,customers_clean.sub_lead_provider
 ,customers_clean.desktop_or_mobile
 ,cast(customers_clean.created_at as date) as prospect_created_date
 ,cast(date_trunc('month',customers_clean.created_at)+interval'1 month - 1 day' as date) as prospect_created_month
 ,case when date_part('month', cast(date_trunc('month',customers_clean.created_at)+interval'1 month - 1 day' as date)) between 1 and 3 then 1
       when date_part('month', cast(date_trunc('month',customers_clean.created_at)+interval'1 month - 1 day' as date)) between 4 and 6 then 2
       when date_part('month', cast(date_trunc('month',customers_clean.created_at)+interval'1 month - 1 day' as date)) between 7 and 9 then 3
       else 4 end as prospect_created_quarter
 ,prospects.subsidy_type
 ,prospects.subsidy_voucher as voucher_amount
 ,prospects.updated_at

 --Showing Data --
 ,showing_counts.total_showing as total_showing_count
 ,showing_counts.showing_missed as missed_showing_count
 ,showing_counts.showing_cancelled as cancelled_showing_count
 ,showing_counts.showing_rescheduled as rescheduled_showing_count
 ,showing_counts.showing_shown as shown_showing_count
 ,showing_counts.showing_pending as pending_showing_count
 ,showing_counts.showings_before_app
 ,showing_counts.showings_after_app
 ,showing_counts.avg_days_out_scheduled
 ,showing_counts.units_visited_count
 ,showing_counts.units_visited_list
 ,showing_counts.showing_set_by_count
 ,showing_counts.showing_set_by_list
 ,showing_counts.first_showing_created
 ,showing_counts.last_showing_created
 ,showing_counts.leasing_agents_shown_list

 --Lease Signing Data --
 ,lease_signings_count.total_lease_signings as lease_signing_count
 ,lease_signings_count.ls_buildings_visited
 ,lease_signings_count.ls_units_visited
 ,lease_signings_count.first_signing_set

 --Approval Data --
 ,applicants.id as applicant_id
 ,case when applicants.id is null then 'N/A'
       when applicants.id = primary_secondary_applicant.primary_applicant_id then 'Primary'
       when applicants.id = primary_secondary_applicant.secondary_applicant_id then 'Secondary'
       else null end as primary_or_secondary_applicant
 ,applicants.ssn_itin
 ,applicants.months_at_residence
 ,applicants.years_at_job
 ,applicants.current_address
 ,applicants.current_city
 ,applicants.current_state
 ,applicants.current_zip
 ,applicants.employer_name
 ,applicants.employer_address
 ,applicants.employer_phone
 ,applicants.is_temp_employee
 ,coalesce(applicants.monthly_income_amount,0) + coalesce(applicants.second_income_amount,0) as monthly_income
 ,applicants.monthly_income_payment_method
 ,applicants.monthly_income_proof
 ,applicants.second_income_payment_method
 ,applicants.second_income_proof
 ,applicants.has_permanent_subsidy
 ,applicants.has_temporary_subsidy
 ,applicants.bank_name
 ,applicants.bank_type
 ,applicants.credit_card_type
 ,coalesce(applicants.number_occupants_over_eighteen,0) as number_occupants_over_eighteen
 ,applicants.first_apartment
 ,applicants.spanish_speaking
 ,applicants.education_level
 ,applicants.employment_type
 ,applicants.salutation
 ,applicants.marriage_status
 ,applicants.school_attending
 ,applicants.school_id
 ,applicants.school_year
 ,applicants.enrollment_status
 ,applicants.financial_aid_organization
 ,applicants.quarterly_aid_provided
 ,applicants.quarterly_aid_for_rent
 ,applicants.years_remaining_on_aid
 ,applicants.fee_collection_type
 ,applicants.verified_by
 ,applicants.original_fee_collection_type
 ,case when lower(applicants.applicant_type) = '' or lower(applicants.applicant_type) like '%paper%' then 'General'
       when lower(applicants.applicant_type) like '%voice%' then 'VA'
       when lower(applicants.applicant_type) like '%kiosk%' then 'Kiosk'
       else 'N/A' end as approval_type
 ,case when prospects.desired_history = '{}' or applicants.has_permanent_subsidy = 't' then prospects.unit_name else split_part(split_part(approval_details.approved_for_unit_reason, 'unit ',2),' ',1) end as application_unit
 ,case when prospects.desired_history = '{}' or applicants.has_permanent_subsidy = 't' then prospects.building_name else split_part(split_part(approval_details.approved_for_unit_reason, 'building ',2),' ',1) end as application_building
 ,case when prospects.desired_history = '{}' or applicants.has_permanent_subsidy = 't' then prospects.unit_name else split_part(split_part(first_approval_details.approved_for_unit_reason, 'unit ',2),' ',1) end as first_application_unit
 ,case when prospects.desired_history = '{}' or applicants.has_permanent_subsidy = 't' then prospects.building_name else split_part(split_part(first_approval_details.approved_for_unit_reason, 'building ',2),' ',1) end as first_application_building
 ,application_details.created_at as application_submitted_on
 ,approval_details.created_at as application_processed_on
 ,approval_details.underwriting_model_id
 ,last_approval.error_count
 ,last_approval.pending_count
 ,last_approval.run_count
 ,approval_details.decision
 --,trim(replace(lp_reports.status_reason,';','')) as decision_reason
 ,approval_details.score
 ,approval_details.process_state
 ,case when approval_details.process_name = 'student' then 'Yes' else 'No' end as student_app
 ,last_application.application_id
 ,case when lp_reports.tier is null then approval_details.tier else lp_reports.tier end as tier
 ,case when lp_reports.amount is null then approval_details.amount else lp_reports.amount end as max_rent
 ,case when lp_reports.move_in_fee is null then approval_details.move_in_fee else lp_reports.move_in_fee end as move_in_fee
 ,case when lp_reports.deposit is null then approval_details.deposit else lp_reports.deposit end as deposit
 ,case when clv_reports.clv is null then applicants.clv else clv_reports.clv end as clv_score
 ,ln_cr.score as fico_score
 ,ln_ev.ev_count_total
 ,ln_ev.ev_count_0_1
 ,ln_ev.ev_count_1_3
 ,ln_ev.ev_count_3_5
 ,ln_ev.ev_count_5_10
 ,ln_ev.ev_count_10_plus
 ,ln_cm.fel_count_total
 ,ln_cm.fel_count_0_3
 ,ln_cm.fel_count_3_5
 ,ln_cm.fel_count_5_10
 ,ln_cm.fel_count_10_plus
 ,ln_cm.misd_count_total
 ,ln_cm.misd_count_0_2
 ,ln_cm.misd_count_2_plus
 ,ln_cm.so_count
 ,case when application_details.id is not null and substr(cached_rendered_hash,(strpos(application_details.cached_rendered_hash,'"evictions_0_to_1_years":') + length('"evictions_0_to_1_years":')),1) ='"' then 'yes' else 'no' end as manual_entry

from customers_clean
left outer join (select *
                 from prospects
                 where prospects.id in(select max(prospects.id) from prospects group by customer_id)) as prospects on customers_clean.id = prospects.customer_id
left outer join (select *
                 from applicants
                 where applicants.id in(select max(applicants.id) from applicants group by customer_id)) as applicants on applicants.customer_id = customers_clean.id
left outer join applicants as applicant_details on applicants.id = applicant_details.id
left outer join units on prospects.desired_unit = units.id
left outer join buildings on units.building_id = buildings.id

--Showings Data -----------------------------------------------------------------------------------------------------------------------------------------

left outer join (select
                  --showings.prospect_id
                  customers_clean.first_name_clean
                  ,customers_clean.last_name_clean
                  ,customers_clean.mobile_phone
                  ,customers_clean.work_phone
                  ,customers_clean.home_phone
                  ,customers_clean.combined
                 ,count(*) as total_showing
                 ,count(case when showings.showable_state = 'showing_set' and showings.start_time < 'today' then 1 else null end) as showing_shown
                 ,count(case when showings.showable_state = 'cancelled' then 1 else null end) as showing_cancelled
                 ,count(case when showings.showable_state = 'rescheduled' then 1 else null end) as showing_rescheduled
                 ,count(case when showings.showable_state = 'missed' then 1 else null end) as showing_missed
                 ,count(case when showings.showable_state = 'showing_set' and showings.start_time > 'today' then 1 else null end) as showing_pending
                 ,count(case when showings.created_at < applicants.created_at then 1 else null end) as showings_before_app
                 ,count(case when showings.created_at > applicants.created_at then 1 else null end) as showings_after_app
                 ,avg(showings.start_time - showings.created_at) as avg_days_out_scheduled
                 ,count(distinct showings.unit_id) as units_visited_count
                 ,string_agg(distinct units.name, ',') as units_visited_list
                 ,count(distinct activities.user) as showing_set_by_count
                 ,string_agg(distinct activities.user,',') as showing_set_by_list
                 ,min(showings.created_at) as first_showing_created
                 ,min(showings.id) as first_showing_id
                 ,max(showings.created_at) as last_showing_created
                 ,string_agg(case when showings.showable_state = 'showing_set' then showings.name else null end,',') as leasing_agents_shown_list

                 from showings
                 left outer join prospects on showings.prospect_id = prospects.id
                 left outer join customers_clean on prospects.customer_id = customers_clean.id
                 left outer join applicants on prospects.id = applicants.prospect_id
                 left outer join units on showings.unit_id = units.id
                 left outer join activities on showings.id = activities.record_id
		               and activities.record_type = 'showing'
                               and activities.action = 'created_showing'
                 group by
                   customers_clean.first_name_clean
                  ,customers_clean.last_name_clean
                  ,customers_clean.mobile_phone
                  ,customers_clean.work_phone
                  ,customers_clean.home_phone
                  ,customers_clean.combined) as showing_counts on
                  --prospects.id = showing_counts.prospect_id
                 (((length(customers_clean.combined) >= length(showing_counts.combined)
                     and ((length(showing_counts.mobile_phone) >=10 and customers_clean.combined like '%'||showing_counts.mobile_phone||'%')
                      or (length(showing_counts.home_phone) >=10 and customers_clean.combined like '%'||showing_counts.home_phone||'%')
                      or (length(showing_counts.work_phone) >=10 and customers_clean.combined like '%'||showing_counts.work_phone||'%')))
                   or((length(customers_clean.combined) < length(showing_counts.combined)
                    and ((length(customers_clean.mobile_phone) >=10 and showing_counts.combined like '%'||customers_clean.mobile_phone||'%')
                     or (length(customers_clean.home_phone) >=10 and showing_counts.combined like '%'||customers_clean.home_phone||'%')
                     or (length(customers_clean.work_phone) >=10 and showing_counts.combined like '%'||customers_clean.work_phone||'%')))))
                and customers_clean.first_name_clean = showing_counts.first_name_clean
		 and customers_clean.last_name_clean = showing_counts.last_name_clean)

--Application/Applicant Data ----------------------------------------------------------------------------------------------------------------------------

left outer join (select applicant_id -- last application that was processed
		,max(applicants_applications.application_id) as application_id
		,min(applicants_applications.application_id) as first_application_id
		from applicants_applications
		left outer join (select max(approvals.application_id) as application_id from approvals group by application_id) as approvals on approvals.application_id = applicants_applications.application_id
	        --where approvals.application_id is not null
		group by applicant_id) as last_application on last_application.applicant_id = applicants.id
left outer join applications as application_details on last_application.application_id = application_details.id --application details
left outer join (select application_id -- to identify applicant as primary or secondary
		,min(applicant_id) as primary_applicant_id
		,case when max(applicant_id) = min(applicant_id) then null else max(applicant_id) end as secondary_applicant_id
		from applicants_applications
		group by application_id) as primary_secondary_applicant on primary_secondary_applicant.application_id = last_application.application_id
 left outer join (select customer_id -- occupants
		 ,min(application_id) as application_id
		 from applications_occupants
		 group by customer_id) as occupant_application on occupant_application.customer_id = customers_clean.id
--CLV Reports --------------------------------------------------------------------------------------------------------------------------------------------
left outer join (select max(clv_sub.subscriber_id) as subscriber_id ,max(clv_sub.third_party_id) as third_party_id
                  from subscriptions as clv_sub
                  where clv_sub.third_party_type = 'ThirdParty::CLVReport'
                  and clv_sub.subscriber_type = 'Applicant'
                  group by clv_sub.subscriber_id) as clv_sub on clv_sub.subscriber_id = applicants.id
left outer join clv_reports on clv_reports.id = clv_sub.third_party_id

--FICO Reports --------------------------------------------------------------------------------------------------------------------------------------------
left outer join (select 
    ln_reports.id
    ,ln_reports.subscriber_id
    ,ln_score.score
  from 
  (select 
  max(lexis_nexis_reports.id) as id
  ,subscriptions.subscriber_id as subscriber_id
  from
  lexis_nexis_reports
  inner join subscriptions on subscriptions.third_party_id = lexis_nexis_reports.id 
      and subscriptions.third_party_type = 'ThirdParty::LexisNexisReport'
      and subscriptions.subscriber_type = 'Applicant'
  where lexis_nexis_reports.status = 'complete'
  and lexis_nexis_reports.report_type = 'CR'
  group by subscriptions.subscriber_id
  ) as ln_reports 
  inner join lexis_nexis_reports as ln_score on ln_score.id = ln_reports.id 
  ) as ln_cr on ln_cr.subscriber_id = applicants.id

--EVC Reports---------------------------------------------------------------------------------------------------------------------------------------------
left outer join (select *
		  from
		 (select max(lexis_nexis_reports.id) as id
		,max(subscriptions.subscriber_id) as subscriber_id
		,max(lexis_nexis_reports.created_at) as created_at
		,max(lexis_nexis_reports.updated_at) as updated_at

		from lexis_nexis_reports
		left outer join subscriptions on subscriptions.third_party_id = lexis_nexis_reports.id
			and subscriptions.third_party_type = 'ThirdParty::LexisNexisReport'
			and subscriptions.subscriber_type = 'Applicant'
		where
		lexis_nexis_reports.status = 'complete'
		and lexis_nexis_reports.report_type = 'EV'
		group by
		subscriptions.subscriber_id) as ln_reports

		left outer join (select lexis_nexis_items.lexis_nexis_report_id
		 ,count(*) as ev_count_total
                 ,count(case when (cast(lexis_nexis_items.created_at as date) - cast(lexis_nexis_items.date as date))/365.0 <= 1.0 then 1 else null end) as ev_count_0_1
                 ,count(case when (cast(lexis_nexis_items.created_at as date) - cast(lexis_nexis_items.date as date))/365.0 <= 3.0
                            and (cast(lexis_nexis_items.created_at as date) - cast(lexis_nexis_items.date as date))/365.0 > 1.0 then 1 else null end) as ev_count_1_3
                 ,count(case when (cast(lexis_nexis_items.created_at as date) - cast(lexis_nexis_items.date as date))/365.0 <= 5.0
                            and (cast(lexis_nexis_items.created_at as date) - cast(lexis_nexis_items.date as date))/365.0 > 3 then 1 else null end) as ev_count_3_5
                 ,count(case when (cast(lexis_nexis_items.created_at as date) - cast(lexis_nexis_items.date as date))/365.0 <= 10.0
                            and (cast(lexis_nexis_items.created_at as date) - cast(lexis_nexis_items.date as date))/365.0 > 5.0 then 1 else null end) as ev_count_5_10
                 ,count(case when (cast(lexis_nexis_items.created_at as date) - cast(lexis_nexis_items.date as date))/365.0 > 10 then 1 else null end) as ev_count_10_plus

                 from lexis_nexis_items
                 where lexis_nexis_items.item_type = 'eviction'
                 group by lexis_nexis_report_id) as ev_items on ln_reports.id = ev_items.lexis_nexis_report_id) as ln_ev on ln_ev.subscriber_id= applicants.id

 --Criminal --------------------------------------------------------------------------------------------------------------------------------------------------------------------
  left outer join (select *
		  from
		 (select max(lexis_nexis_reports.id) as id
		,max(subscriptions.subscriber_id) as subscriber_id
		,max(lexis_nexis_reports.created_at) as created_at
		,max(lexis_nexis_reports.updated_at) as updated_at

		from lexis_nexis_reports
		left outer join subscriptions on subscriptions.third_party_id = lexis_nexis_reports.id
			and subscriptions.third_party_type = 'ThirdParty::LexisNexisReport'
			and subscriptions.subscriber_type = 'Applicant'
		where
		lexis_nexis_reports.status = 'complete'
		and lexis_nexis_reports.report_type = 'CM'
		group by
		subscriptions.subscriber_id) as ln_reports

		left outer join (select lexis_nexis_items.lexis_nexis_report_id
		 ,count(*) as fel_count_total
                 ,count(case when (cast(lexis_nexis_items.created_at as date) - cast(lexis_nexis_items.date as date))/365.0 <= 3.0 then 1 else null end) as fel_count_0_3
                 ,count(case when (cast(lexis_nexis_items.created_at as date) - cast(lexis_nexis_items.date as date))/365.0 > 3.0
                            and (cast(lexis_nexis_items.created_at as date) - cast(lexis_nexis_items.date as date))/365.0 <= 5.0 then 1 else null end) as fel_count_3_5
                 ,count(case when (cast(lexis_nexis_items.created_at as date) - cast(lexis_nexis_items.date as date))/365.0 > 5.0
                            and (cast(lexis_nexis_items.created_at as date) - cast(lexis_nexis_items.date as date))/365.0 <= 10 then 1 else null end) as fel_count_5_10
                 ,count(case when (cast(lexis_nexis_items.created_at as date) - cast(lexis_nexis_items.date as date))/365.0 > 10 then 1 else null end) as fel_count_10_plus

                 from lexis_nexis_items
                 where lexis_nexis_items.item_type = 'felony'
                 group by lexis_nexis_report_id) as fel_items on ln_reports.id = fel_items.lexis_nexis_report_id

                left outer join (select lexis_nexis_items.lexis_nexis_report_id
                 ,count(*) as misd_count_total
                 ,count(case when (cast(lexis_nexis_items.created_at as date) - cast(lexis_nexis_items.date as date))/365.0 <= 2.0 then 1 else null end) as misd_count_0_2
                 ,count(case when (cast(lexis_nexis_items.created_at as date) - cast(lexis_nexis_items.date as date))/365.0 > 2.0 then 1 else null end) as misd_count_2_plus

                 from lexis_nexis_items
                 where lexis_nexis_items.item_type = 'misdemeanor'
                 group by lexis_nexis_report_id) as misd_items on ln_reports.id = misd_items.lexis_nexis_report_id

                 left outer join (select lexis_nexis_items.lexis_nexis_report_id
                 ,count(*) as so_count

                 from lexis_nexis_items
                 where lexis_nexis_items.item_type = 'sex offense'
                 group by lexis_nexis_report_id) as so_items on ln_reports.id = so_items.lexis_nexis_report_id) as ln_cm on ln_cm.subscriber_id= applicants.id

--Approval Data -----------------------------------------------------------------------------------------------------------------------------------------

left outer join (select max(approvals.id) as approval_id -- last approval
                 ,application_id
                 ,sum(case when lower(approvals.decision) like '%error%' then 1 else 0 end) as error_count
                 ,sum(case when lower(approvals.decision) like '%pending manager%' then 1 else 0 end) as pending_count
                 ,sum(case when lower(approvals.process_state) like '%underwritten%' then 1 else 0 end) as run_count
                 from approvals
                 --where
                 --approvals.replaced_by is null
                 --and approvals.process_state = 'underwritten'
                 group by application_id) as last_approval on last_application.application_id = last_approval.application_id
left outer join approvals as approval_details on approval_details.id = last_approval.approval_id -- approval details
left outer join legacy_process_approval_reports as lp_reports on lp_reports.approval_id = last_approval.approval_id

left outer join (select min(approvals.id) as approval_id -- first approval of first application
                 ,application_id
                 from approvals
                 where
                 approvals.process_state like '%underwritten%'
                 group by application_id) as first_approval on last_application.first_application_id = first_approval.application_id
left outer join approvals as first_approval_details on first_approval.approval_id = first_approval_details.id

--Lease Signings Data ----------------------------------------------------------------------------------------------------------------------------------

left outer join (select prospect_id
                 ,count(*) as total_lease_signings
                 ,count(case when lease_signings.showable_state = 'lease_signing_set' and lease_signings.start_time < 'today' then 1 else null end) as ls_shown
                 ,count(case when lease_signings.showable_state = 'cancelled' then 1 else null end) as ls_cancelled
                 ,count(case when lease_signings.showable_state = 'rescheduled' then 1 else null end) as ls_rescheduled
                 ,count(case when lease_signings.showable_state = 'missed' then 1 else null end) as ls_missed
                 ,count(case when lease_signings.showable_state = 'lease_signing_set' and lease_signings.start_time > 'today' then 1 else null end) as ls_pending
                 ,min(lease_signings.created_at) as first_signing_set
                 ,string_agg(distinct cast(buildings.name as varchar),',') as ls_buildings_visited
                 ,string_agg(distinct cast(units.name as varchar),',') as ls_units_visited

                  from lease_signings
                  left outer join units on lease_signings.unit_id = units.id
                  left outer join buildings on buildings.id = units.building_id
                  group by prospect_id) as lease_signings_count on lease_signings_count.prospect_id = prospects.id

left outer join (select *
                 from lease_signings
                 where
                 lease_signings.id in(select max(lease_signings.id)
                                        from lease_signings
                                        where lease_signings.showable_state = 'lease_signing_set'
                                        group by prospect_id)) as lease_signings on lease_signings.prospect_id = prospects.id
-------------------------------------------------------------------------------------------------------------------------------------------------------------
where
  occupant_application.customer_id is null
  --and application_details.id is not null
  --and substr(cached_rendered_hash,(strpos(application_details.cached_rendered_hash,'"evictions_0_to_1_years":') + length('"evictions_0_to_1_years":')),1) ='"'

  --and customers_clean.sub_lead_provider is null

order by
  customers_clean.created_at
