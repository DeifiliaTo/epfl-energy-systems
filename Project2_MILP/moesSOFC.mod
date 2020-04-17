/*---------------------------------------------------------------------------------------------------------------------------------------
Set the efficiencis of the SOFC and thermal/electricity output ratio
Table A.1, https://www.sciencedirect.com/science/article/pii/S0306261917316045
---------------------------------------------------------------------------------------------------------------------------------------*/
param eff_thermal default 0.2734 ;

param eff_electrical default 0.538;

param TER default 2 ;
/*---------------------------------------------------------------------------------------------------------------------------------------
Set flow rate of biogas as a function of efficiencies
---------------------------------------------------------------------------------------------------------------------------------------*/

let Flowin['Biogas', 'SOFC']  := Qheatingsupply['SOFC'] / eff_thermal;
#let Flowout['Electricity', 'SOFC']  := Flowin['Biogas', 'SOFC'] * eff_electrical; 
