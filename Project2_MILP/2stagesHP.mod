/*---------------------------------------------------------------------------------------------------------------------------------------
Set the efficiency of 2stagesHP
---------------------------------------------------------------------------------------------------------------------------------------*/
param eff_carnot default 0.64;

/*---------------------------------------------------------------------------------------------------------------------------------------
Set the electricity output as a function of Th, Tc and Heat to supply to the buildings
---------------------------------------------------------------------------------------------------------------------------------------*/

/*?????LOOP LOW TEMPERATURE OR LOOP HIGH TEMPERATURE */
Flowin['Electricity','2stagesHP'] = (Qheatingsupply['2stagesHP']*(Th_LT-Tlmc)) / (eff_carnot*Th_LT) ;  /* Qheatingsupply is Q+calculated or the name of de variable is not correct?*/
Flowin['Electricity','2stagesHP'] = (Qheatingsupply['2stagesHP']*(Th_MT-Tlmc)) / (eff_carnot*Th_MT) ;  /* */

Flowin['Heat','2stagesHP'] = Qheatingsupply['2stagesHP'] - Electricity['2stagesHP']
