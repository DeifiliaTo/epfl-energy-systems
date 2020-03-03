function Build = Buildings(building_name)

%% PREAMBLE
% Course: Modelling and Optimisation of Energy Systems
% Project: Energy demands of the EPFL campus
% Authors: Francesca Belfiore
% Last modified: 18/2-2020
%
% Description: function to CALL to calculate, for A GIVEN building:
% (1) the internal heat gains 
% (2) the building envelope properties (Newton-Raphson)
% (3) the hourly heating demand
% (4) the typical periods (clustering)
%% 

%% DATA MANAGEMENT
%  Do NOT modify

% Initial parameters
h = 8760;                   % Number of hours in a year
T_th = 16;                  % Cut-off temperature of the heating system [�C]
cp_air = 1152;              % Specific heat capacity of the air [J/m3/K] 
T_int = 21;                 % Set point (comfort) temperature [C]
air_new = 2.5;              % Air renewal [m3/m2]
Vent = air_new*cp_air/3600; % Ventilation capacity

% Call of the weather data
filename = 'P1_weatherdata.csv';
data_w = csvread(filename,1,0);
Text = data_w(:,1);         % External temperature [C]
Irr = data_w(:,2);          % Global solar irradiation [W/m2]

% Call of the buildings data
filename = 'P1_buildingsdata.csv';
fid = fopen(filename);
format = '%s%f%f%f%f';
data = textscan(fid, format, 'Headerlines', 1, 'delimiter', ',');
name = data{1,1};

% Index and variable definition
index = find(ismember(name, building_name));
Build.ground = data{1,3}(index);    % Building heated surface [m2]
Build.Q = data{1,4}(index);         % Building annual heat load [kWh]
Build.El = data{1,5}(index);        % Building annual electricity consumption [kWh]

%% TASK 1 - Calculation of the internal heat gains (appliances & humans)

% 1.1 - Electronic appliances and lights for each buildings

% fractional profiles
p.elec.day.f  = [0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 0 0];
p.elec.week.f = [repmat(p.elec.day.f,5,1);zeros(2,24)];
p.elec.year.f = [repmat(p.elec.week.f,52,1);p.elec.day.f];

% total hours (should equal 3654, s1.2.1)
p.elec.totalHours = sum(p.elec.year.f,'all');

% fraction of electricity demand converted to heat (s1.1)
f_el = 0.8; %[-]

% hourly heating power of electricals
Q_el = Build.El * f_el / p.elec.totalHours; %[kW]

% electrical heating profiles
p.elec.day.v  = p.elec.day.f  * Q_el; %[kW]
p.elec.week.v = p.elec.week.f * Q_el; %[kW]
p.elec.year.v = p.elec.year.f * Q_el; %[kW]

% 1.2 - Presence of people (all the buildings are the same, s1.2.2)
Heat_gain = [5, 35, 23.3, 0];       %[W/m^2]
Share     = [0.3, 0.05, 0.35, 0.3]; %[-]

% Occupation profile for office, restaurant and classroom from 1am to 12am
% (fig 1.1)
p.occ.office = [0 0 0 0 0 0 0 0.2 0.4 0.6 0.8 0.8 0.4 0.6 0.8 0.8 0.4 0.2 0 0 0 0 0 0]; %[-]
p.occ.rest   = [0 0 0 0 0 0 0 0   0.4 0.2 0.4 1   0.4 0.2 0.4 0   0   0   0 0 0 0 0 0]; %[-]
p.occ.class  = [0 0 0 0 0 0 0 0.4 0.6 1   1   0.8 0.2 0.6 1   0.8 0.8 0.4 0 0 0 0 0 0]; %[-]
p.occ.other  = zeros(1,24);                                                             %[-]

% Matrix of occupation profile for office, restaurant, classroom and other
p.occ.day.f = [p.occ.office; p.occ.rest; p.occ.class; p.occ.other]; %[-]

% Specific heat gain by people for a building from 1am to 12am
q_people.day  = sum((p.occ.day.f' .* (Heat_gain .* Share))')*3.6; %[kJ/m^2/h]
q_people.week = [repmat(q_people.day,5,1);zeros(2,24)];
q_people.year = [repmat(q_people.week,52,1);q_people.day];

%% TASK 2 - Calculation of the building thermal properties (kth and ksun)

% First equation - switching ON the heating system ==> Qth

% Second equation - yearly heating demand ==> q_plus_year

% Implementation of the Newton-Raphson method
    % Method initialisation
    
    % Resolution
    
k0 = [2, 2]; %initial guess
[k,fval, exitflag, output] = fsolve(@(k) q_objective(1, Build.ground, k(1), T_int, Text, k(2), Irr, q_people.year, f_el, p.elec.year.v, Build.Q), k0);
 
Build.kth = k(1);
Build.ksun = k(2);
 
U_env = Build.kth - air_new*cp_air; %[W/(m^2.K)]

Results = table(Build.kth,Build.ksun,U_env,fval,output.iterations);

%% TASK 3 - Estimation of the hourly profile    

% Hourly demand (thermal load)

%% TASK 4 - Clustering of the heating demand
% based on the hourly heating demand (typical periods)
    
