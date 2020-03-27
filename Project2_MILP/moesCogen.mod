/*---------------------------------------------------------------------------------------------------------------------------------------
Setup variables
---------------------------------------------------------------------------------------------------------------------------------------*/

var Cogen_Hbo{Time} >=0;
var Cogen_Hchp{Time} >=0;
var Cogen_Echp{Time} >=0;

/*---------------------------------------------------------------------------------------------------------------------------------------
Set efficiency parameters - Table 1, DOI 10.1016/j.applthermaleng.2014.02.051
---------------------------------------------------------------------------------------------------------------------------------------*/
param Cogen_eta_bo default 0.9;     # -

param Cogen_eta_Echp default 0.3;   # -

param Cogen_eta_Hchp default 0.9;   # -

param Cogen_pci default 13.9;       # kWh/kg

/*---------------------------------------------------------------------------------------------------------------------------------------
Constraints
---------------------------------------------------------------------------------------------------------------------------------------*/

# Heat balance (12)
subject to Cogen_heat:
    Qheatingsupply['Cogen'] = sum {t in Time} ( Cogen_Hbo[t] + Cogen_Hchp[t] )
;

# Electricity balance (11, modified)
subject to Cogen_elec:
    Flowout['Electricity','Cogen'] = sum {t in Time} Cogen_Echp[t]
;

# Gas demand (5, 6, 9)
subject to Cogen_gas:
    Flowin['Natgas','Cogen'] = 1/Cogen_pci * sum {t in Time} ( Cogen_Hbo[t]/Cogen_eta_bo + Cogen_Hchp[t]/Cogen_eta_Hchp + Cogen_Echp[t]/Cogen_eta_Echp )
;
