/*---------------------------------------------------------------------------------------------------------------------------------------
Set the efficiencis of the SOFC and thermal/electricity output ratio
---------------------------------------------------------------------------------------------------------------------------------------*/
param eff_thermal default 0.538 ;

param eff_electrical default 0.2734;

param TER default 2 ;
/*---------------------------------------------------------------------------------------------------------------------------------------
Set flow rate of biogas as a function of efficiencies
---------------------------------------------------------------------------------------------------------------------------------------*/
let Flowin['Biogas','SOFC'] := Qheatingsupply['SOFC'] * (1/ eff_thermal + 1/(eff_electrical*TER)); 

let Flowout['Electricity','SOFC'] := Qheatingsupply['SOFC'] / TER;
