set1 = {'sensitivity-c_spec-NatGasGrid'...
    'sensitivity-c_spec-ElecGridBuy'...
    'sensitivity-c_spec-ElecGridSell'...
    'sensitivity-c_CO2-Natgas'...
    'sensitivity-c_CO2-Electricity'};

set2 = {'pareto-front-CO2-InvCost-c_CO2-Natgas-overview'...
    'pareto-front-CO2-InvCost-c_spec-ElecGridBuy-overview'...
    'pareto-front-CO2-InvCost-c_spec-NatGasGrid-overview'...
    'pareto-front-CO2-TotalCost-c_CO2-Natgas-overview'...
    'pareto-front-CO2-TotalCost-c_spec-ElecGridBuy-overview'...
    'pareto-front-CO2-TotalCost-c_spec-NatGasGrid-overview'...
    'pareto-front-OpCost-InvCost-c_CO2-Natgas-overview'...
    'pareto-front-OpCost-InvCost-c_spec-ElecGridBuy-overview'...
    'pareto-front-OpCost-InvCost-c_spec-NatGasGrid-overview'};

for file = set2
    file = char(file);
    fig = openfig(['figures/' file '.fig']);
    
%     moveTitleToLegend(fig)
    
    figExport(8,8,file)
end

function alignTitleRight
% change title alignment to right of plot
% export changes limits later so doesn't look right though
ax = gca;
ax.Title.HorizontalAlignment = 'right';
pos = ax.Title.Position;
pos(1) = ax.XLim(2);
ax.Title.Position = pos;
end

function moveTitleToLegend(fig)
lgd = findobj(fig,'type','legend');
ax = gca;
lgd.Title.String = ax.Title.String;
lgd.Title.Interpreter = ax.Title.Interpreter;
ax.Title.String ='';
end
