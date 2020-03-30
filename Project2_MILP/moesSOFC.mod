/*---------------------------------------------------------------------------------------------------------------------------------------
Set the efficiencis of the SOFC and thermal/electricity output ratio
---------------------------------------------------------------------------------------------------------------------------------------*/
param eff_thermal default 0.538 ;

param eff_electrical default 0.2734;

param TER default 2 ;
/*---------------------------------------------------------------------------------------------------------------------------------------
Set flow rate of biogas as a function of efficiencies
---------------------------------------------------------------------------------------------------------------------------------------*/
#subject to SOFC_Biogas:
#    Flowin['Biogas', 'SOFC'] * mult['SOFC'] = Qheatingsupply['SOFC'] * (1/ eff_thermal + 1/(eff_electrical*TER))
#;


let Flowin['Biogas', 'SOFC']  := Qheatingsupply['SOFC'] * (1/ eff_thermal + 1/(eff_electrical*TER));
let Flowout['Electricity', 'SOFC']  := Qheatingsupply['SOFC'] / TER; 

#subject to SOFC_elec:
#    Flowout['Electricity', 'SOFC'] * mult['SOFC'] = Qheatingsupply['SOFC'] / TER;   
#;

