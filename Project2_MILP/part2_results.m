
function part2_results()
% Generate 4 graphs
heating_supply
capex
E_supply
E_usage
end


function heating_supply()
Q = zeros(6, 3);
cogen = [14978.36	14523.06	2007.06	3840.64	0	37949.9];
twostg = [1039.78	1039.78	0	0	0	1039.78];
onestg = [10000	10000	0	0	0	10000];

for i = 1:6
    Q(i, 1) = cogen(i);
    Q(i, 2) = twostg(i);
    Q(i, 3) = onestg(i);
end

heat_plt = bar(Q, 'stacked')
xlabel('Time period')
ylabel('Heating supply [kW]')
legend('Cogeneration', '2-stage heat pump', '1-stage heat pump (LT)', 'Location', 'northwest');
figExport(12, 8, 'heat_supply')

end

function capex()
costs = [355828.0496 86690.7217 1162149.096 152598.0475];
labels = {'Cogeneration', '2-stage heat pump', '1-stage heat pump', 'PV'};
explode = [1 1 1 1];
capex_plt = pie(costs,explode,'%2.0f%%')
legend(labels, 'Location', 'southwest')

figExport(10, 10, 'capex')
end

function E_supply()
E = zeros(6, 3);
grid = [0	0	8558.09	8032.28	2244.97	0];
cogen = [14978.4	14523.1	2007.06	3840.63	0	30957.5];
PV = [277.28	235.895	1671.95	364.188	401.435	0];

for i = 1:6
    E(i, 1) = grid(i);
    E(i, 2) = cogen(i);
    E(i, 3) = PV(i);
end

E_supply = bar(E, 'stacked')
xlabel('Time period')
ylabel('Electricity supply [kW]')
legend('Grid', 'Cogeneration', 'PV', 'Location', 'northwest');
figExport(12, 8, 'E_supply')


end

function E_usage()
E = zeros(6, 4);
demand = [12237.1	12237.1	12237.1	12237.1	2626.4	12237.1];
onestg = [2069.68	2012.03	0	0	0	2242.62];
twostg = [509.828	509.828	0	0	0	510];
sell = [439.029	0	0	0	0	15968];

for i = 1:6
   E(i, 1) = demand(i);
   E(i, 2) = onestg(i);
   E(i, 3) = twostg(i);
   E(i, 4) = sell(i);
end
E
E_usage = bar(E, 'stacked')
xlabel('Time period')
ylabel('Electricity usage [kW]')
legend('Demand', '1-stage heat pump', '2-stage heat pump', 'sell', 'Location', 'northwest');
figExport(12, 8, 'E_usage')

end

function figExport(w,h,name)
fig = gcf;
fig.PaperOrientation = 'landscape';
fig.PaperSize = [w h];
fig.PaperPosition = [0 0 w h];
% fig.Renderer = 'Painters'; % for 3D plots
print(gcf, '-dpdf', [pwd '/figures/' name '.pdf']);
end