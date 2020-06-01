for front = {'CO2-InvCost' 'CO2-TotalCost' 'OpCost-InvCost'}
    front = char(front);
    
    for var = {'c_spec-ElecGridBuy' 'c_spec-NatGasGrid' 'c_CO2-Natgas'}
        var = char(var);
        var_ = split(var,'-');
        
        close all
        
        filePrefix = ['pareto-front-' front];
        files = {[filePrefix '-' var '-50.fig'] [filePrefix '.fig'] [filePrefix '-' var '-200.fig']};
        
        % iterate through input figures
        for n = 1:numel(files)
            orig(n).fig = openfig(['figures/' files{n}]);
            
            % copy others into figure 1
            if n ~= 1
                L = findobj(orig(n).fig,'type','line');
                copyobj(L,findobj(1,'type','axes'));
            end
        end
        
        % close all but figure 1
        close(setdiff(1:numel(files),1))
        
        % add title
        figure(1)
        title([var_{1} '[''' var_{2} ''']'],'Interpreter','none')
        legend('50%','100%','200%')
        
        % recolour lines
        for n = 1:numel(orig(1).fig.CurrentAxes(1).Children)
            orig(1).fig.CurrentAxes(1).Children(n).Color = orig(1).fig.CurrentAxes(1).ColorOrder(n,:);
        end
        % set color index for next plots
        orig(1).fig.CurrentAxes(1).ColorOrderIndex = n+1;
        
        figExport(12,12,['pareto-front-' front '-' var '-overview']);
        
    end
end
