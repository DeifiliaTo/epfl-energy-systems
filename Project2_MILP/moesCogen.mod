/*---------------------------------------------------------------------------------------------------------------------------------------
Setup variables
---------------------------------------------------------------------------------------------------------------------------------------*/

var Cogen_Hchp >=0;                 # [kW]
var Cogen_Echp >=0;                 # [kW]

/*---------------------------------------------------------------------------------------------------------------------------------------
Set efficiency parameters - Fig 19.2 https://doi.org/10.1016/B978-1-78242-269-3.50019-X (EPFL login required)
---------------------------------------------------------------------------------------------------------------------------------------*/

param Cogen_eta_Echp default 0.35;  # [-]
param Cogen_eta_Hchp default 0.5;   # [-]

/*---------------------------------------------------------------------------------------------------------------------------------------
Constraints
---------------------------------------------------------------------------------------------------------------------------------------*/

# Electricity balance (11, modified)
subject to Cogen_elec:
    Flowout['Electricity','Cogen'] = Cogen_Echp
;

# output ratio (assumption)
subject to Cogen_eta:
    Cogen_Echp / Cogen_eta_Echp = Cogen_Hchp / Cogen_eta_Hchp
;

# Gas demand (5, 6, 9)
subject to Cogen_gas:
    Flowin['Natgas','Cogen'] = Cogen_Hchp/Cogen_eta_Hchp + Cogen_Echp/Cogen_eta_Echp
;

# Heat balance (12)
subject to Cogen_heat:
    Qheatingsupply['Cogen'] = Cogen_Hchp
;
