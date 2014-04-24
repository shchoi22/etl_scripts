select 
  portfolioabbreviation as portfolio
  ,buildingabbreviation as building
  ,zonename as zone
  ,zonepm as property_manager
  ,leasingagent as leasing_agent
  ,address
  ,neighborhood
  ,city
  ,state
  ,cast(unitcount as int) as unit_count
  ,cast(vacantunitcount as int) as vacant_unit_count
  ,assetacquisitiondate as asset_acquisition_date
  ,managementtakeoverdate as management_takeover_date
from pw_building

