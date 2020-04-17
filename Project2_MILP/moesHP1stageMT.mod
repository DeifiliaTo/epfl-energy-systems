/*---------------------------------------------------------------------------------------------------------------------------------------
Set the efficiency of 1-stagesHP MT
---------------------------------------------------------------------------------------------------------------------------------------*/
param eff_carnotMT default 0.55;
param Th_HP1stageMT default 327.9; #K

#No lake temperature variation with time
#param Tlmc_HP1stageMT default 278;             # water is taken from the lake at 4C and is rejected at 6C

#Lake temperature variation with time
param Tlmc_HP1stageMT{t in Time} := (Tlake[t]-3)/log((Tlake[t]+273)/(3+273)); #water is taken from the lake at Tlake and returned at 3�C

/*---------------------------------------------------------------------------------------------------------------------------------------
Set the electricity output as a function of Th, Tc and Heat to supply to the buildings
---------------------------------------------------------------------------------------------------------------------------------------*/

#No lake temperature variation with time
#let Flowin['Electricity','HP1stageMT'] := Qheatingsupply['HP1stageMT'] * (Th_HP1stageMT - Tlmc_HP1stageMT) / (eff_carnotMT * Th_HP1stageMT);

#Lake temperature variation with time
subject to ElecHP1MT {t in Time}:
    FlowInUnit['Electricity','HP1stageMT',t] = Qheatingsupply['HP1stageMT'] * mult_t['HP1stageMT',t] * (Th_HP1stageMT - Tlmc_HP1stageMT[t]) / (eff_carnotMT * Th_HP1stageMT);
  
