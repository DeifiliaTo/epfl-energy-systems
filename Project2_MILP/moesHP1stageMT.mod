/*---------------------------------------------------------------------------------------------------------------------------------------
Set the efficiency of 1-stagesHP MT
---------------------------------------------------------------------------------------------------------------------------------------*/
param eff_carnotMT default 0.55;
param Th_HP1stageMT default 327.9 ; #K

param Tlmc_HP1stageMT default 278;             # water is taken from the lake at 4C and is rejected at 6C

#param Tlmc_HP1stageMT{t in Time} := (Tlake[t]-3)/log((Tlake[t]+273)/(3+273)); #water is taken from the lake at Tlake and returned at 3�C

/*---------------------------------------------------------------------------------------------------------------------------------------
Set the electricity output as a function of Th, Tc and Heat to supply to the buildings
---------------------------------------------------------------------------------------------------------------------------------------*/

/*?????LOOP LOW TEMPERATURE OR LOOP HIGH TEMPERATURE */
let Flowin['Electricity','HP1stageMT'] := (Qheatingsupply['HP1stageMT'] * (Th_HP1stageMT - Tlmc_HP1stageMT)) / (eff_carnotMT * Th_HP1stageMT) ;
/* Qheatingsupply is Q+calculated or the name of de variable is not correct?*/

# Flowin['Heat','HP2stage'] = Qheatingsupply['HP2stage'] - Electricity['HP2stage'] ;
# why are we trying to calculate heat supplied to the pump? we don't care about this afaik...


#subject to HP1stageMT_elecIn{t in Time}:
 #Flowin['Electricity','HP1stageMT']  = (Qheatingsupply['HP1stageMT']* mult_t['HP1stageMT',t] * (Th_HP1stageMT - Tlmc_HP1stageMT[t])) / (eff_carnotMT * Th_HP1stageMT) ;
 
# subject to COP_MT{t in Time}:
# COP['HP1stageMT',t]=  (eff_carnotLT * Th_HP1stageMT)/(Th_HP1stageMT - Tlmc_HP1stageMT[t]);
 
