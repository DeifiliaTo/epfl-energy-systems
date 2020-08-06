
function part5_results()
% Generate 
total_cost_scenario
CO2
E_bought
E_gen
gas_bought
end


function total_cost_scenario()
C = zeros(4, 2);
CAPEX	= [20.1416	1.32372	20.1529	2.87669];
OPEX	= [9.63932	12.573	10.8592	12.251];

X = categorical({'min OPEX', 'min TOTEX', 'Self-sufficient', 'CO_2 tax'});
X = reordercats(X, {'min OPEX', 'min TOTEX', 'Self-sufficient', 'CO_2 tax'});

for i = 1:4
    C(i, 1) = CAPEX(i);
    C(i, 2) = OPEX(i);
end

Cost_plt = bar(X, C, 'stacked')
xlabel('Scenarios')
ylabel('Total Cost [MCHF/yr]')
legend('CAPEX', 'OPEX', 'Location', 'northeast');
figExport(8, 6, 'Cost_scenario')

end

function CO2()
CO2 = [8033.95	16347.1	353.325	11569.1];

X = categorical({'min OPEX', 'min TOTEX', 'Self-sufficient', 'CO_2 tax'});
X = reordercats(X, {'min OPEX', 'min TOTEX', 'Self-sufficient', 'CO_2 tax'});

CO2_plt = bar(X, CO2, 'stacked')
xlabel('Scenarios')
ylabel('CO_2 Emissions [t/yr]')

figExport(8, 6, 'CO2')
end

function E_bought()
t = zeros(6, 4);
t_1 = [0	0	12613.4	0];
t_2 = [0	0	12267.5	0];
t_3 = [9216.35	8558.09	9377.25	9216.35];
t_4 = [9291.91	8032.28	9456.74	10981.4];
t_5 = [2244.97	2244.97	2244.97	2244.97];
t_6 = [0	0	13112.7	0];


for i = 1:4
    t(i, 1) = t_1(i);
    t(i, 2) = t_2(i);
    t(i, 3) = t_3(i);
    t(i, 4) = t_4(i);
    t(i, 5) = t_5(i);
    t(i, 6) = t_6(i);
end
t = t'; 

bar(t)
xlabel('Time period')
ylabel('Electricity bought from grid [kW]')
legend('min OPEX', 'min TOTEX', 'Self-sufficient', 'CO2', 'Location', 'southwest');
figExport(8, 6, 'E_bought')


end

function E_gen()
t = zeros(6, 4);
t_1 = [14160.51	16444.98	5077.28	14965.58];
t_2 = [14009.545	15948.295	5035.895	14468.895];
t_3 = [3020.75	3679.01	2859.84	3020.75];
t_4 = [2945.188	4204.818	2780.368	1712.988];
t_5 = [401.435	401.435	401.435	401.435];
t_6 = [13454.55	39139.2	4800	37659.8];

for i = 1:4
    t(i, 1) = t_1(i);
    t(i, 2) = t_2(i);
    t(i, 3) = t_3(i);
    t(i, 4) = t_4(i);
    t(i, 5) = t_5(i);
    t(i, 6) = t_6(i);
end
t = t'; 

bar(t)
xlabel('Time period')
ylabel('Electricity generated [kW]')
legend('min OPEX', 'min TOTEX', 'Self-sufficient', 'CO2', 'Location', 'northwest');
figExport(8, 6, 'E_gen')

end


function gas_bought()
t = zeros(6, 4);
t_1 = [24974.5	44453.4	0	36677.1];
t_2 = [24673.2	43201.6	0	35425.3];
t_3 = [0	5518.44	0	0];
t_4 = [0	10559.9	0	0];
t_5 = [0	0	0	0];
t_6 = [23795.9	107614	0	99837.8];

for i = 1:4
    t(i, 1) = t_1(i);
    t(i, 2) = t_2(i);
    t(i, 3) = t_3(i);
    t(i, 4) = t_4(i);
    t(i, 5) = t_5(i);
    t(i, 6) = t_6(i);
end
t = t'; 

bar(t)
xlabel('Time period')
ylabel('Natural gas from grid [kW]')
legend('min OPEX', 'min TOTEX', 'Self-sufficient', 'CO2', 'Location', 'northwest');
figExport(8, 6, 'gas_bought')

end


function figExport(w,h,name)
fig = gcf;
fig.PaperOrientation = 'landscape';
fig.PaperSize = [w h];
fig.PaperPosition = [0 0 w h];
% fig.Renderer = 'Painters'; % for 3D plots
print(gcf, '-dpdf', [pwd '/figures/' name '.pdf']);
end