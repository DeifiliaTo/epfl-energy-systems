/*---------------------------------------------------------------------------------------------------------------------------------------
Set the efficiency of 2stagesHP
---------------------------------------------------------------------------------------------------------------------------------------*/
param eff_carnotLT default 0.55;
param Th_HP1stageLT default 315.4; #K

#param Tlmc_HP1stage default 278;             # water is taken from the lake at 4C and is rejected at 6C

param Tlmc_HP1stageLT{t in Time}  := (Tlake[t]-3)/log((Tlake[t]+273)/(3+273)); #water is taken from the lake at Tlake and returned at 3�C
/*---------------------------------------------------------------------------------------------------------------------------------------
Set the electricity output as a function of Th, Tc and Heat to supply to the buildings
---------------------------------------------------------------------------------------------------------------------------------------*/


/*?????LOOP LOW TEMPERATURE OR LOOP HIGH TEMPERATURE */
#let Flowin['Electricity','HP1stageLT'] := (Qheatingsupply['HP1stageLT'] * (Th_HP1stageLT - Tlake[t]) / (eff_carnotLT * Th_HP1stageLT) ;
/* Qheatingsupply is Q+calculated or the name of de variable is not correct?*/

# Flowin['Heat','HP2stage'] = Qheatingsupply['HP2stage'] - Electricity['HP2stage'] ;
# why are we trying to calculate heat supplied to the pump? we don't care about this afaik...

subject to HP1stageLT_elecIn{t in Time}:
 Flowin['Electricity','HP1stageLT']  = (Qheatingsupply['HP1stageLT'] * mult_t['HP1stageLT',t]* (Th_HP1stageLT - Tlmc_HP1stageLT[t])) / (eff_carnotLT * Th_HP1stageLT) ;