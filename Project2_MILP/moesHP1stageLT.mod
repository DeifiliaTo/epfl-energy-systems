/*---------------------------------------------------------------------------------------------------------------------------------------
Set the efficiency of 2stagesHP
---------------------------------------------------------------------------------------------------------------------------------------*/
param eff_carnotLT default 0.55;
param Th_HP1stageLT default 315.4; #K

#No lake temperature variation with time
#param Tlmc_HP1stageLT default 278;             # water is taken from the lake at 4C and is rejected at 6C

#Lake temperature variation with time
param Tlmc_HP1stageLT{t in Time} := (Tlake[t]-3)/log((Tlake[t]+273)/(3+273)); #water is taken from the lake at Tlake and returned at 3�C

/*---------------------------------------------------------------------------------------------------------------------------------------
Set the electricity output as a function of Th, Tc and Heat to supply to the buildings
---------------------------------------------------------------------------------------------------------------------------------------*/

#No lake temperature variation with time
#let Flowin['Electricity','HP1stageLT'] := Qheatingsupply['HP1stageLT'] * (Th_HP1stageLT - Tlmc_HP1stageLT) / (eff_carnotLT * Th_HP1stageLT) ;

#Lake temperature variation with time
subject to ElecHP1LT {t in Time}:
    FlowInUnit['Electricity','HP1stageLT',t] = Qheatingsupply['HP1stageLT'] * mult_t['HP1stageLT',t] * (Th_HP1stageLT - Tlmc_HP1stageLT[t]) / (eff_carnotLT * Th_HP1stageLT);
