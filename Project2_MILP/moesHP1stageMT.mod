/*---------------------------------------------------------------------------------------------------------------------------------------
Set the efficiency of 2stagesHP
---------------------------------------------------------------------------------------------------------------------------------------*/
param eff_carnotMT default 0.64;
param Th_HP1stageMT default 298;

param Tlmc_HP1stageMT default 278;             # water is taken from the lake at 4C and is rejected at 6C

/*---------------------------------------------------------------------------------------------------------------------------------------
Set the electricity output as a function of Th, Tc and Heat to supply to the buildings
---------------------------------------------------------------------------------------------------------------------------------------*/

/*?????LOOP LOW TEMPERATURE OR LOOP HIGH TEMPERATURE */
let Flowin['Electricity','HP1stageMT'] := (Qheatingsupply['HP1stageMT'] * (Th_HP1stageMT - Tlmc_HP1stageMT)) / (eff_carnotMT * Th_HP1stageMT) ;
/* Qheatingsupply is Q+calculated or the name of de variable is not correct?*/

# Flowin['Heat','HP2stage'] = Qheatingsupply['HP2stage'] - Electricity['HP2stage'] ;
# why are we trying to calculate heat supplied to the pump? we don't care about this afaik...