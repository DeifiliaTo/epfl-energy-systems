/*---------------------------------------------------------------------------------------------------------------------------------------
Set the efficiencis of the SOFC and thermal/electricity output ratio
---------------------------------------------------------------------------------------------------------------------------------------*/
param eff_thermal default 0.2734 ;

param eff_electrical default 0.538;

param TER default 0.52 ;
/*---------------------------------------------------------------------------------------------------------------------------------------
Set flow rate of biogas as a function of efficiencies
---------------------------------------------------------------------------------------------------------------------------------------*/

let Flowout['Electricity', 'SOFC']  := Qheatingsupply['SOFC'] / TER; 

let Flowin['Biogas', 'SOFC']  := (Qheatingsupply['SOFC']+Flowout['Electricity', 'SOFC']) / (eff_thermal + eff_electrical);




