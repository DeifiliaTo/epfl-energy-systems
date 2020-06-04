%% inset plots
close all

%% Pareto: OpCost/InvCost

file = 'pareto-front-OpCost-InvCost';
fig = openfig(['figures/' file '.fig']);

makeInsetPlot(fig,[.4 .4 .45 .45],[1e7 1.1e7],[0.5e7 1e7]);

figExport(8,8,[file '-inset'])

%% Pareto: CO2/TotalCost

file = 'pareto-front-CO2-TotalCost';
fig = openfig(['figures/' file '.fig']);

makeInsetPlot(fig,[.4 .4 .45 .45],[0 1e6],[1.65e7 1.75e7]);

figExport(8,8,[file '-inset'])

%% Pareto: CO2/InvCost

file = 'pareto-front-CO2-InvCost';
fig = openfig(['figures/' file '.fig']);

makeInsetPlot(fig,[.4 .4 .45 .45],[0 3e6],[2e6 5e6]);

% plot characteristic points to be discussed
hold on
plot([2164416.83 566846.1154 449630.8092],...
    [2621302.401 3005827.901 4632430.973],'m*');

figExport(8,8,[file '-inset'])

%% function space

function makeInsetPlot(fig,pos,xlim,ylim)

% create inset axes
ax2 = axes('Position',pos);
box on

% copy same line to inset
copyobj(findobj(fig,'type','line'),ax2);

ax2.XLim = xlim;
ax2.YLim = ylim;

end
