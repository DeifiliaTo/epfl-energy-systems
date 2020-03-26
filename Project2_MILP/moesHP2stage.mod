/*---------------------------------------------------------------------------------------------------------------------------------------
Set the efficiency of 2stagesHP
---------------------------------------------------------------------------------------------------------------------------------------*/
param eff_carnot := 0.64;

/*---------------------------------------------------------------------------------------------------------------------------------------
Set the hot and cold temperature
---------------------------------------------------------------------------------------------------------------------------------------*/

param Tlmc_HP2stage := 5;             # water is taken from the lake at 4C and is rejected at 6C

/*---------------------------------------------------------------------------------------------------------------------------------------
Set the electricity output as a function of Th, Tc and Heat to supply to the buildings
---------------------------------------------------------------------------------------------------------------------------------------*/

/*?????LOOP LOW TEMPERATURE OR LOOP HIGH TEMPERATURE */
let Flowin['Electricity','HP2stage'] := sum{h in HeatingLevel} (Qheatingsupply['HP2stage'] * (Theating[h] - Tlmc_HP2stage)) / (eff_carnot * Theating[h]) ;
/* Qheatingsupply is Q+calculated or the name of de variable is not correct?*/

# Flowin['Heat','HP2stage'] = Qheatingsupply['HP2stage'] - Electricity['HP2stage'] ;
# why are we trying to calculate heat supplied to the pump? we don't care about this afaik...