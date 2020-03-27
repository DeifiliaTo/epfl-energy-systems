clear all
clc

%% Utility data

% Table with the utilities and the corresponding lifetime and fixed (1) 
% and variable (2), investment (cinv) and operating (cop) costs

Utility = {'Boiler'; 'PV'; 'SOFC'; 'Geothermal'; 'HP2stage'; ...
    'HP1stageLT'; 'HP1stageMT'; 'Cogen'}; % Utility name
n =     [0; 0; 0; 30; 0; 0; 0; 0]; % Lifetime in [years]
cinv1 = [0; 773; 383; 0; 0; 0; 0; 0]; % Fixed investment cost in [CHF]
cinv2 = [0; 1; 8788; 3922; 0; 0; 0; 0]; % Variable investment cost in [CHF / (kWcapacity * year)]
cop1 =  [0; 0; 0; 0; 0; 0; 0; 0]; % Fixed operating cost in [CHF / hr]
cop2 =  [0; 0; 0.0577; 0.0245; 0; 0; 0; 0]; % Variable operating cost in [CHF / (kWproduction * hr)]

T = table (Utility, n, cinv1, cinv2, cop1, cop2);

T_an = T;

% Interest rate
i = 0.08;

%% Annualized costs

% Annualized factor
F = (i * (1 + i).^n) ./ ((1 + i).^n - 1);

% Annualized investment costs
T_an.cinv1 = T.cinv1 .* F;
T_an.cinv2 = T.cinv2 .* F;

