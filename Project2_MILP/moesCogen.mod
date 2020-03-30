/*---------------------------------------------------------------------------------------------------------------------------------------
Set efficiency parameters
---------------------------------------------------------------------------------------------------------------------------------------*/

# default values from fig 19.2 of https://doi.org/10.1016/B978-1-78242-269-3.50019-X (EPFL login required)
param Cogen_eta_Echp default 0.35;  # [-]
param Cogen_eta_Hchp default 0.5;   # [-]

# fit to a function based on plant size
# (Excel; based on Table 9 of https://ec.europa.eu/energy/sites/ener/files/documents/Article%2014_1EEDGermanyEN.pdf)
let Cogen_eta_Echp := 0.3627 + 5e-7 * Flowout['Electricity','Cogen'];
let Cogen_eta_Hchp := 0.5102 - 5e-7 * Flowout['Electricity','Cogen'];

/*---------------------------------------------------------------------------------------------------------------------------------------
Equations
---------------------------------------------------------------------------------------------------------------------------------------*/

let Qheatingsupply['Cogen'] := Flowout['Electricity','Cogen'] * Cogen_eta_Hchp/Cogen_eta_Echp;
let Flowin['Natgas','Cogen'] := Qheatingsupply['Cogen']/Cogen_eta_Hchp + Flowout['Electricity','Cogen']/Cogen_eta_Echp;
