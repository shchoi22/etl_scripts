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

from pw_unit