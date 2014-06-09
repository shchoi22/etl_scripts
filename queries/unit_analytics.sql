select
  buildingname as building
  ,unitabbreviation as unit
  ,cast(daysvacant as int) as days_vacant
  ,targetrent as target_rent
  ,totalarea as total_area
  ,showinginstructions as showing_instructions
  ,unitamenities as unit_amenities
  ,status
  ,type as unit_type
  ,estimatedavailabledate as est_available_date
  ,availabledate as available_date
  ,cast(bedrooms as int) as bedrooms
  ,cast(bathrooms as int) as bathrooms
  ,case when unitamenities not like '%Not Available%'
       and unitabbreviation not like '%Neighborhood%'
       and status !='Occupied'
       and cast(availabledate as date) between '1900-01-02' and 'today'
       and monthlyrent != '0.00'
       and type not in('RETAIL','COMM','Office')
       and type not like '%RETAIL%' and type not like '%COMM%'
       and subsidy = '--' then 'Yes' else 'No' end as ready_to_show
from pw_unit
