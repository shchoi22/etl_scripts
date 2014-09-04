
with
 pw_leases as
   (select pw_lease.leasename
     ,pw_lease.createdtime
     ,replace(pw_lease.primarycontactfirstname,'-',' ') as primarycontactfirstname
     ,replace(pw_lease.primarycontactlastname,'-',' ') as primarycontactlastname
     ,replace(replace(replace(replace(pw_lease.primarycontacthomephone,' ',''),'-',''),'(',''),')','') as home_phone
     ,replace(replace(replace(replace(pw_lease.primarycontactmobile,' ',''),'-',''),'(',''),')','') as mobile_phone
     ,replace(replace(replace(replace(pw_lease.primarycontactworkphone,' ',''),'-',''),'(',''),')','') as work_phone
     ,(case when length(replace(replace(replace(replace(pw_lease.primarycontacthomephone,' ',''),'-',''),'(',''),')','')) >=10
                 then replace(replace(replace(replace(pw_lease.primarycontacthomephone,' ',''),'-',''),'(',''),')','') else '' end) ||
      (case when length(replace(replace(replace(replace(pw_lease.primarycontactmobile,' ',''),'-',''),'(',''),')','')) >=10
                 then replace(replace(replace(replace(pw_lease.primarycontactmobile,' ',''),'-',''),'(',''),')','') else '' end) ||
      (case when length(replace(replace(replace(replace(pw_lease.primarycontactworkphone,' ',''),'-',''),'(',''),')','')) >= 10
                 then replace(replace(replace(replace(pw_lease.primarycontactworkphone,' ',''),'-',''),'(',''),')','') else '' end) as combined_phone
    from pw_lease
    join (select
           pw_lease.primarycontactfirstname as first_name
          ,pw_lease.primarycontactlastname as last_name
          ,pw_lease.primarycontactmobile || pw_lease.primarycontacthomephone || pw_lease.primarycontactworkphone as combined
          ,min(cast(pw_lease.createdtime as timestamp)) as converted_date
         from pw_lease
         group by
           first_name
          ,last_name
          ,combined) as move_within_pangea on pw_lease.primarycontactfirstname = move_within_pangea.first_name
                                           and pw_lease.primarycontactlastname = move_within_pangea.last_name
                                           and cast(pw_lease.createdtime as timestamp) = move_within_pangea.converted_date )

SELECT
   cast(prospect_data.id as int) as customer_id
  ,prospect_data.first_name
  ,prospect_data.last_name
  ,prospect_data.mobile_phone
  ,prospect_data.work_phone
  ,prospect_data.home_phone
  ,prospect_data.combined
  ,prospect_data.email
  ,case when prospect_data.dob ='' then null else cast(prospect_data.dob as date) end as date_of_birth
  ,cast(prospect_data.created as timestamp) as created_at
  ,case when prospect_data.prospect_id ='' then null else cast(cast(prospect_data.prospect_id as numeric) as int) end as prospect_id
  ,case when prospect_data.prospect_desired_beds ='' then null else cast(cast(prospect_data.prospect_desired_beds as numeric) as int) end as prospect_desired_beds
  ,case when prospect_data.prospect_desired_baths ='' then null else cast(cast(prospect_data.prospect_desired_baths as numeric) as int) end as prospect_desired_baths
  ,prospect_data.prospect_desired_location
  ,case when prospect_data.prospect_number_of_occupants ='' then null else cast(cast(prospect_data.prospect_number_of_occupants as numeric) as int) end as prospect_number_of_occupants
  ,prospect_data.prospect_number_of_pets
  ,case when prospect_data.prospect_move_in_date ='' then null else cast(prospect_data.prospect_move_in_date as date) end as prospect_move_in_date
  ,prospect_data.prospect_income_source
  ,prospect_data.prospect_evictions_within_twelve_months
  ,prospect_data.prospect_felonies_within_three_years
  ,case when prospect_data.prospect_monthly_income ='' then null else cast(prospect_data.prospect_monthly_income as numeric) end as prospect_monthly_income
  ,prospect_data.prospect_reason_not_converting
  ,prospect_data.prospect_subsidy_voucher
  ,prospect_data.prospect_building_name
  ,prospect_data.prospect_unit_name
  ,case when prospect_data.prospect_waitlisted_at ='' then null else cast(prospect_data.prospect_waitlisted_at as timestamp) end prospect_waitlisted_at
  ,prospect_data.prospect_desired_history
  ,prospect_data.desired_building_name
  ,prospect_data.desired_unit_name
  ,case when prospect_data.sub_lead_provider = '' then null else prospect_data.sub_lead_provider end as sub_lead_provider
  ,case when prospect_data.sub_lead_provider in('ADWLP','BDSADW','CPSADW','GA250','GA350','GA450','GAAS8','GAGEN','GAUBN','GAUBN8','GCHAT',
                                                'GCHAT8','GCHI','GCHI8','GCHIB','GCHIC','GCHILP','GCREDIT','GIND','GIND8','GINDB','GINDC',
                                                'GNHS','GNHS8','GOOG','Google','GPANLP','GPF','GPF8','GSECTLP','GSS','GSS8','LANDADW','LOCCADW',
                                                'LOCSADW','LOWLOCADW ','MADW','P2CADW','PCADW','PSADW','SECSADW','STHSADW','WSTSADW ','SCOLLEGE',
                                                'MARIAN','GBRAND','GCOMP','GCONTS8','GZONE1','GZONE2','GZONE3','GZONE4','GZONE5','GZONE20','GZONE21'
                                                ) then 'Adwords'
       when prospect_data.sub_lead_provider in('CATH','FFIST','HCP','HEART','INNER','INSPIR','UCAN','PATH') then 'Agency'
       when prospect_data.sub_lead_provider in('AGB','FRB') then 'AptBooks'
       when prospect_data.sub_lead_provider in('BING','BINGC8','PFBING','BZONE1','BZONE2','BZONE3','BINGBRAND','BINGBRAND') then 'BING'
       when prospect_data.sub_lead_provider in('CRAI','CRAIAG','CRAIE','CBT','CRAIN','CIT','CMY','CAG','CAS','CMYTST','CAGTST','CS8','CTW',
                                               'CAT','CMT','CLB','CPW','CGR','CRL','CVL','CCL','CHL','CML','CVY','CFL','CCE','CTT','CF2','CAH','CA2','CHW','JBC','CJB') then 'Craigslist'

       when prospect_data.sub_lead_provider in('74','77','B103','B742','B774','BCHI','BCTA74','BG74','BG77','BGCHI','BSAD77','BUS','BUS13',
                                               'BUS77','CTA77','GLCTA','GLH9','GLINE3','GREEN','GREENRED','GRN4','LGRN8','LINE','RAIL','RCTA',
                                               'RDL3','RDLSPRING','RED','REDAD','REDH9','REDL4','REDWIN12','RLINE2','RLN8','STOP','TRAIN',
                                               'HYDEPARK','REDLINE13','GREENLINE13','REDAD14') then 'CTA'
       when prospect_data.sub_lead_provider in('DIAL') then 'Dialer-Port'
       when prospect_data.sub_lead_provider in('EMAPTG','JM250','JM324','JM350','JM424','JM450','JME282','LFPRE') then 'Email-ACQ'
       when prospect_data.sub_lead_provider in('APP2100','APP4250','APPCTA3','HEAT25','MORE100','NEW25','REAC224','RLU2','RLU3','RLU3',
                                               'SHOWA100','SHOWA25','SPECIALS25','VALUE25','WORD') then 'Email-Port'
       when prospect_data.sub_lead_provider in('FBOOK','FACEBOOK') then 'Facebook'
       when prospect_data.sub_lead_provider in('SEC8LIST','S8QM','GSEC8') then 'GSEC8'
       when prospect_data.sub_lead_provider in('GSWAG','PWHO','VINEHO','CTSHO','HILLHO','GROHO','VISHO','CEDHO','RIVHO','GINFLY',
                                               'SPINGHO','GRCOL','RICOL','IHF') then 'Guerilla'
       when prospect_data.sub_lead_provider in('TISD') then 'IndyStar'
       when prospect_data.sub_lead_provider in('OODLE','YAHO') then 'Internet'
       when prospect_data.sub_lead_provider in('ACON','AHLS','APA','AXONAS','BHR','CAF','CHIA','CITYWIDE','DREAM','DRT','DWELL','ELAN','GOTV','HANSEN','HOUSE',
                                               'HPR','HURA','INFINITE','JABS','JADE','JCON','KALE','KARBON','KELLER','KELLY','LOOP','LPRO','MALLARD',
                                               'MREALTY','MYAPT','NATI','NCMBC','NGATE','OLAD','PROEQ','R2R','REFUGE','REMAX','RENEW','RKP','ROCK',
                                               'ROYAL','RPM','RPREALTY','RUFF','SPU','TIMBER','THRESHOLDS','TNR','TPH','TROCK','UASP','URENT','YVET','WEP','CASS',
                                               'WUBB','AMERICAN','PSTREET','WINNIE','ATEAM','FULTON','URBAN','SIWEL') then 'LeasingAgency'
      when prospect_data.sub_lead_provider in('LACH1','LACH2','LACH3','LACH4','LACH5','LACH6','LACH7','LAB1','LAB2','LAB3','LAB4','LAIN1',
                                              'LAIN2','LAIN3','LAIN4','LAIN5','LAIN6','LAIN7') then 'LeasingAgent'
      when prospect_data.sub_lead_provider in('APAR','APTG','CHAW','CORT','DOMU','FORRENT','RENT','RNTLS','ALIST') then 'ListingSites'
      when prospect_data.sub_lead_provider in('GPZ1','GPZ2','GPZ3','GPZ4','GPPW','GPMD','GPCD','GPVY','GPRS','GPVS','GPHLS','GPGRV','GPPF','GPZ1',
                                              'GPZ2','GPZ3','GPZ4','GPZ30','GPCTS','BPZ30','BPRS','BPCD','BPVY','BPVT','BPHLS','BPCTS',
                                              'BPGRV','BPPW','BPZ1','BPZ2','BPZ3','BPZ4','BPPF','GPDREX') then 'Local'
      when prospect_data.sub_lead_provider in('APTFD','HOTP','MOVE','NEWP','RTHOME','GSEC8','ILIH','PADMAP','RBITS','RMINT','ZILLOW') then 'LS2'
      when prospect_data.sub_lead_provider in('M1250','M2559','M283','M3559','M446','M643','MAQE34','INDYESP','INDYMAIL') then 'Mail-ACQ'
      when prospect_data.sub_lead_provider in('MRE24') then 'Mail-Port'
      when prospect_data.sub_lead_provider in('MPAN23','MPAN24','MPAN34') then 'Mail-Port2'
      when prospect_data.sub_lead_provider in('MED') then 'Metra'
      when prospect_data.sub_lead_provider in('MOBILE') then 'MOBILE'
      when prospect_data.sub_lead_provider in('310HOUSE','ChathamT','COLES416','Coles7834','COLS7601','COLS7706','HOUSE','ING8155','INGS8051',
                                              'MAR8236','MHOUSE','OHCED','OHPW','PF0310','PF0602','PF3324','SShoreOH','SSOH','state7929','SV21746',
                                              'VAFAIR','Z4HOUSE','PF504','8127SE','PF518','CHAT518','PF601','CHAT608','OHFLYER','OH718','727OH',
                                              'KS727','SS727','727ST','OH713','801OH','OHSTR','FLYOH','OAKSOH','PFOH') then 'OpenHouse'
      when prospect_data.sub_lead_provider in('ATTPPC','Other') then 'Other'
      when prospect_data.sub_lead_provider in('INDB','IndyGO','TASTE','PACE') then 'OUTDOOR'
      when prospect_data.sub_lead_provider in('AUSW','BULL','CHIJ','DEFE','FRB','HYDE','LAVOZ','NICKEL','SKYL','SOUT','STAR','STOWN','TRIB',
                                              'VOIC','WIND','STAROL','DEXBOOK','FRIBC','FRVY','FRVS','FRPW','FRGV') then 'Publication'
      when prospect_data.sub_lead_provider in('1063','1390','923','WEDJ','RADIO','W107','WNTS','LALEY') then 'Radio'
      when prospect_data.sub_lead_provider in('PANR') then 'Referral'
      when prospect_data.sub_lead_provider in('GREM') then 'Remarketing'
      when prospect_data.sub_lead_provider in('PANGEARE','AGSEO','AUSTSEO','CHATAPT','CHATSEO','CHIAPT','CHICHEAP','CHILOW','CHISEC8','CHISEO',
                                              'INDYAPT','INDYCHEAP','INDYLOW','INDYSEC8','NHSAPT','NSEO','PFAPT','S8SEO','SHORESEO','SSHOREAPT',
                                              'STHSEO','ISEOCED','ISEOHLS','ISEOPW','ISEORS','ISEOVY','ISEOVST','ISEOCTS','ISEOGRV','CSEOPP',
                                              'CSEO','ISEO','BSEO','OKSITE','PNSITE','PWSITE','CDSITE','RSDSITE','HLSITE','MDSITE','VYSITE',
                                              'VSTSITE','CTSITE','GVSITE','FDSITE','PFTSITE') then 'SEO'
      when prospect_data.sub_lead_provider in('PANB','PANBSF','BAN2013','PFSIGN','RSSIGN','CDSIGN','VYSIGN','VTSIGN','HLSIGN','GRSIGN','PWSIGN',
                                              'CTSIGN','INDYFLYER','BALTFLYER','HOSTR','SSFEST','STSHIRT','INGLAWN','STREET','S8FLY','STHO') then 'Signage'
      when prospect_data.sub_lead_provider in('STIMES','STLA','STOWN','SUN250','SUNC','SUNT','SUNT','SUNTSS') then 'SunTimes'
      when prospect_data.sub_lead_provider in('END','MID','REMSSF','RTXEM','RTXEM','SHOWTXT') then 'Text-Port'
      when prospect_data.sub_lead_provider in('AM26','BGC','BSOUTH','BSUB','CLTV','CWPP','CWPRE','EVE26','FOX','NEWS','SUNCW','TVPAN',
                                              'WCIU','WGN') then 'TV'
      when lower(prospect_data.sub_lead_provider) in('walk') then 'Walk'
      when prospect_data.master_lead_provider ='' then 'none'
      else prospect_data.master_lead_provider end as master_lead_provider
  ,case when prospect_data.sub_lead_provider in('ACON','AHLS','APA','AXONAS','BHR','CAF','CHIA','CITYWIDE','DREAM','DRT','DWELL','ELAN','GOTV','HANSEN','HOUSE',
                                               'HPR','HURA','INFINITE','JABS','JADE','JCON','KALE','KARBON','KELLER','KELLY','LOOP','LPRO','MALLARD',
                                               'MREALTY','MYAPT','NATI','NCMBC','NGATE','OLAD','PROEQ','R2R','REFUGE','REMAX','RENEW','RKP','ROCK',
                                               'ROYAL','RPM','RPREALTY','RUFF','SPU','TIMBER','THRESHOLDS','TNR','TPH','TROCK','UASP','URENT','YVET','WEP','CASS',
                                               'WUBB','AMERICAN','PSTREET','WINNIE','ATEAM','FULTON','URBAN','SIWEL') then 'yes' else 'no' end as agency
  ,prospect_data.desktop_or_mobile
  ,prospect_data.subsidy_type
  ,prospect_data.voucher_amount
  ,case when prospect_data.updated_at = '' then null else cast(prospect_data.updated_at as timestamp) end as updated_at
  ,case when prospect_data.applicant_id ='' then null else cast(cast(prospect_data.applicant_id as numeric) as int) end as applicant_id
  ,case when prospect_data.application_id ='' then null else cast(cast(prospect_data.application_id as numeric) as int) end as application_id
  ,cast(cast(secondary.id as numeric) as int) as secondary_customer_id
  ,secondary.prospect_id as secondary_prospect_id
  ,secondary.first_name as secondary_first_name
  ,secondary.last_name as secondary_last_name
  ,secondary.applicant_id as secondary_applicant_id
  ,case when pw_leases.leasename is null then pw_leases_sec.leasename else pw_leases.leasename end as lease_name
  ,case when prospect_data.first_showing_created ='' then null else cast(prospect_data.first_showing_created as timestamp) end as first_showing_created
  ,case when prospect_data.application_submitted_on = '' then null else cast(prospect_data.application_submitted_on as timestamp) end as application_submitted_on
  ,case when prospect_data.application_processed_on = '' then null else cast(prospect_data.application_processed_on as timestamp) end application_processed_on
  ,case when prospect_data.total_showing_count ='' then 0 else cast(cast(prospect_data.total_showing_count as numeric) as int) end as total_showing_count
  ,case when prospect_data.missed_showing_count ='' then 0 else cast(cast(prospect_data.missed_showing_count as numeric) as int) end as missed_showing_count
  ,case when prospect_data.cancelled_showing_count ='' then 0 else cast(cast(prospect_data.cancelled_showing_count as numeric) as int) end as cancelled_showing_count
  ,case when prospect_data.rescheduled_showing_count ='' then 0 else cast(cast(prospect_data.rescheduled_showing_count as numeric) as int) end as rescheduled_showing_count
  ,case when prospect_data.shown_showing_count ='' then 0 else cast(cast(prospect_data.shown_showing_count as numeric) as int) end as shown_showing_count
  ,case when prospect_data.pending_showing_count ='' then 0 else cast(cast(prospect_data.pending_showing_count as numeric) as int) end as pending_showing_count
  ,case when prospect_data.showings_before_app ='' then 0 else cast(cast(prospect_data.showings_before_app as numeric) as int) end as showings_before_app
  ,case when prospect_data.showings_after_app = '' then 0 else cast(cast(prospect_data.showings_after_app as numeric) as int) end as showings_after_app
  --,case when prospect_data.avg_days_out_scheduled = '' then null else cast(prospect_data.avg_days_out_scheduled as interval) end as avg_days_out_scheduled
  ,case when prospect_data.units_visited_count='' then 0 else cast(cast(prospect_data.units_visited_count as numeric) as int) end as units_visited_count
  ,case when prospect_data.units_visited_list = '' then null else prospect_data.units_visited_list end as units_visited_list
  ,case when prospect_data.showing_set_by_count = '' then 0 else cast(cast(prospect_data.showing_set_by_count as numeric) as int) end as showing_set_by_count
  ,case when prospect_data.showing_set_by_list ='' then null else prospect_data.showing_set_by_list end as showing_set_by_list
  ,case when prospect_data.last_showing_created = '' then null else cast(prospect_data.last_showing_created as timestamp) end as last_showing_created
  ,case when prospect_data.leasing_agents_shown_list = '' then null else prospect_data.leasing_agents_shown_list end as leasing_agents_shown_list
  ,case when prospect_data.lease_signing_count = '' then 0 else cast(cast(prospect_data.lease_signing_count as numeric) as int) end as lease_signing_count
  ,case when prospect_data.ls_buildings_visited ='' then null else prospect_data.ls_buildings_visited end as ls_buildings_visited
  ,case when prospect_data.ls_units_visited = '' then null else prospect_data.ls_units_visited end as ls_units_visited
  ,case when prospect_data.first_signing_set = '' then null else cast(prospect_data.first_signing_set as timestamp) end as first_signing_set
  ,prospect_data.primary_or_secondary_applicant
  ,prospect_data.approval_type
  ,prospect_data.decision
  ,prospect_data.score
  ,prospect_data.max_rent
  ,prospect_data.move_in_fee
  ,prospect_data.deposit
  ,prospect_data.tier
  ,prospect_data.original_fee_collection_type
  ,prospect_data.fee_collection_type
  ,prospect_data.verified_by
  ,prospect_data.error_count
  ,prospect_data.pending_count
  ,prospect_data.run_count
  ,prospect_data.process_state
  ,prospect_data.underwriting_model_id
  ,prospect_data.student_app
  ,prospect_data.clv_score
  ,prospect_data.ssn_itin
  ,prospect_data.months_at_residence
  ,prospect_data.years_at_job
  ,prospect_data.current_address
  ,prospect_data.current_city
  ,prospect_data.current_state
  ,prospect_data.current_zip
  ,prospect_data.employer_name
  ,prospect_data.employer_address
  ,prospect_data.employer_phone
  ,prospect_data.is_temp_employee
  ,prospect_data.monthly_income_payment_method
  ,prospect_data.monthly_income_proof
  ,prospect_data.second_income_payment_method
  ,prospect_data.second_income_proof
  ,prospect_data.has_permanent_subsidy
  ,prospect_data.has_temporary_subsidy
  ,prospect_data.bank_name
  ,prospect_data.bank_type
  ,prospect_data.credit_card_type
  ,prospect_data.number_occupants_over_eighteen
  ,prospect_data.first_apartment
  ,prospect_data.spanish_speaking
  ,prospect_data.education_level
  ,prospect_data.employment_type
  ,prospect_data.salutation
  ,prospect_data.marriage_status
  ,prospect_data.school_attending
  ,prospect_data.school_id
  ,prospect_data.school_year
  ,prospect_data.enrollment_status
  ,prospect_data.financial_aid_organization
  ,prospect_data.quarterly_aid_provided
  ,prospect_data.quarterly_aid_for_rent
  ,prospect_data.years_remaining_on_aid
  ,prospect_data.ev_count_total
  ,prospect_data.ev_count_0_1
  ,prospect_data.ev_count_1_3
  ,prospect_data.ev_count_3_5
  ,prospect_data.ev_count_5_10
  ,prospect_data.ev_count_10_plus
  ,prospect_data.fel_count_total
  ,prospect_data.fel_count_0_3
  ,prospect_data.fel_count_3_5
  ,prospect_data.fel_count_5_10
  ,prospect_data.fel_count_10_plus
  ,prospect_data.misd_count_total
  ,prospect_data.misd_count_0_2
  ,prospect_data.misd_count_2_plus
  ,prospect_data.so_count
  ,prospect_data.manual_entry


FROM

  (select prospect_data.*
          ,dups.id as dups_id
          ,dups.combined as dups_combined
   from (select * from pcore_prospect_data where pcore_prospect_data.primary_or_secondary_applicant <> 'Secondary') as prospect_data
   left outer join pcore_prospect_data as dups on prospect_data.id <> dups.id
                                         and dups.application_processed_on !=''
                                         and
                                         ((length(prospect_data.combined) >= length(dups.combined)

                                         and ((length(dups.mobile_phone) >=10 and prospect_data.combined like '%'||dups.mobile_phone||'%')
                                             or (length(dups.home_phone) >=10 and prospect_data.combined like '%'||dups.home_phone||'%')
                                             or (length(dups.work_phone) >=10 and prospect_data.combined like '%'||dups.work_phone||'%')))
                                         or((length(prospect_data.combined) < length(dups.combined)
                                         and ((length(prospect_data.mobile_phone) >=10 and dups.combined like '%'||prospect_data.mobile_phone||'%')
                                             or (length(prospect_data.home_phone) >=10 and dups.combined like '%'||prospect_data.home_phone||'%')
                                             or (length(prospect_data.work_phone) >=10 and dups.combined like '%'||prospect_data.work_phone||'%')))))
                                         and prospect_data.first_name = dups.first_name
					 and prospect_data.last_name = dups.last_name

    where dups.id is null) as prospect_data

  left outer join (select *
                   from pcore_prospect_data
                   where pcore_prospect_data.primary_or_secondary_applicant = 'Secondary') as secondary on prospect_data.application_id = secondary.application_id

  left outer join pw_building on prospect_data.desired_building_name = pw_building.buildingabbreviation

  left outer join pw_leases on --Primary
                  (((length(prospect_data.mobile_phone) >=10 and
                  pw_leases.combined_phone like '%'||prospect_data.mobile_phone||'%') or
                   (length(prospect_data.home_phone) >=10 and
                   pw_leases.combined_phone like '%'||prospect_data.home_phone||'%') or
                   (length(prospect_data.work_phone) >=10 and
                   pw_leases.combined_phone like '%'||prospect_data.work_phone||'%')) and
                  prospect_data.first_name = lower(pw_leases.primarycontactfirstname) and
                  prospect_data.last_name = lower(pw_leases.primarycontactlastname))
                  and cast(pw_leases.createdtime as date) >= cast(prospect_data.created as date)

  left outer join pw_leases as pw_leases_sec on --Secondary
                  (((length(secondary.mobile_phone) >=10 and
                  pw_leases_sec.combined_phone like '%'||secondary.mobile_phone||'%') or
                   (length(secondary.home_phone) >=10 and
                   pw_leases_sec.combined_phone like '%'||secondary.home_phone||'%') or
                   (length(secondary.work_phone) >=10 and
                   pw_leases_sec.combined_phone like '%'||secondary.work_phone||'%')) and
                  secondary.first_name = lower(pw_leases_sec.primarycontactfirstname) and
                  secondary.last_name = lower(pw_leases_sec.primarycontactlastname))
                  and cast(pw_leases_sec.createdtime as date) >= cast(secondary.created as date)


where
 prospect_data.first_name != ''
 and prospect_data.last_name !=''
 --and prospect_data.created >= '2013-10-01'

order by
 prospect_data.first_name
 ,prospect_data.last_name
