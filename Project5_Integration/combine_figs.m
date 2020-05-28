files.ElecGridBuy = {'pareto-front-CO2-TotalCost-c_spec-ElecGridBuy-50.fig'...
    'pareto-front-CO2-TotalCost.fig'...
    'pareto-front-CO2-TotalCost-c_spec-ElecGridBuy-200.fig'};
files.NatGasGrid = {'pareto-front-CO2-TotalCost-c_spec-NatGasGrid-50.fig'...
    'pareto-front-CO2-TotalCost.fig'...
    'pareto-front-CO2-TotalCost-c_spec-NatGasGrid-200.fig'};

for set = {'ElecGridBuy' 'NatGasGrid'}
    set = char(set);
    close all
    
    % iterate through input figures
    for n = 1:numel(files.(set))
        orig(n).fig = openfig(['figures/' files.(set){n}]);
        
        % copy others into figure 1
        if n ~= 1
            L = findobj(orig(n).fig,'type','line');
            copyobj(L,findobj(1,'type','axes'));
        end
    end
    
    % close all but figure 1
    close(setdiff(1:numel(files.(set)),1))
    
    % add title
    figure(1)
    title(['c_spec[''' set ''']'],'Interpreter','none')
    legend('50%','100%','200%')
    
    % recolour lines
    for n = 1:numel(orig(1).fig.CurrentAxes(1).Children)
        orig(1).fig.CurrentAxes(1).Children(n).Color = orig(1).fig.CurrentAxes(1).ColorOrder(n,:);
    end
    % set color index for next plots
    orig(1).fig.CurrentAxes(1).ColorOrderIndex = n+1;
    
    figExport(12,12,['pareto-front-CO2-TotalCost-c_spec-' set '-overview']);
    
end
