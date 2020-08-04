/*---------------------------------------------------------------------------------------------------------------------------------------
Set the efficiency of 2stagesHP
---------------------------------------------------------------------------------------------------------------------------------------*/
param eff_carnotLT_3 default 0.55;
param Th_HP1stageLT_3 default 315.4; #K

# #No lake temperature variation with time
#param Tlmc_HP1stageLT default 278;             # water is taken from the lake at 4C and is rejected at 6C

# #Lake temperature variation with time
param Tlmc_HP1stageLT_3{t in Time} := (3)/log((Tlake[t]+273)/(Tlake[t]-3+273)); #water is taken from the lake at Tlake and returned at 3�C

/*---------------------------------------------------------------------------------------------------------------------------------------
Set the electricity output as a function of Th, Tc and Heat to supply to the buildings
---------------------------------------------------------------------------------------------------------------------------------------*/

#No lake temperature variation with time
#let Flowin['Electricity','HP1stageLT_3'] := Qheatingsupply['HP1stageLT_3'] * (Th_HP1stageLT - Tlmc_HP1stageLT) / (eff_carnotLT * Th_HP1stageLT) ;

#Lake temperature variation with time
subject to ElecHP1LT_3 {t in Time}:
    FlowInUnit['Electricity','HP1stageLT_3',t] = Qheatingsupply['HP1stageLT_3'] * mult_t['HP1stageLT_3',t] * (Th_HP1stageLT_3 - Tlmc_HP1stageLT_3[t]) / (eff_carnotLT_3 * Th_HP1stageLT_3);
