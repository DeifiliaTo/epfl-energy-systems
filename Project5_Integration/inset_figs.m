%% inset plots
close all

%% Pareto: OpCost/InvCost

file = 'pareto-front-OpCost-InvCost';
openfig(['figures/' file '.fig']);

ax = gca;
ax.XLim = [1e7 1.1e7];
ax.YLim = [0.5e7 1e7];

figExport(6,6,[file '-inset'])

%% Pareto: CO2/TotalCost

file = 'pareto-front-CO2-TotalCost';
openfig(['figures/' file '.fig']);

ax = gca;
ax.XLim = [0 1e6];
ax.YLim = [1.65e7 1.75e7];

figExport(6,6,[file '-inset'])

%% Pareto: CO2/InvCost

file = 'pareto-front-CO2-InvCost';
openfig(['figures/' file '.fig']);

ax = gca;
ax.XLim = [0 3e6];
ax.YLim = [2e6 5e6];

% plot characteristic points to be discussed
hold on
plot([2164416.83 566846.1154 449630.8092],...
    [2621302.401 3005827.901 4632430.973],'m*');

figExport(6,6,[file '-inset'])