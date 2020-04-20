%% Data import (Buildings.csv)
filename = 'P1_buildingsdata.csv';
fid = fopen(filename);
format = '%s%f%f%f%f%f';
data = textscan(fid,format,'Headerlines',1,'delimiter',',');
name = data{1,1};
n_build = length(name);

%%
el = zeros(n_build, 1);

filename = 'P1_buildingsdata.csv';
fid = fopen(filename);
format = '%s%f%f%f%f';
data = textscan(fid, format, 'Headerlines', 1, 'delimiter', ',');
name = data{1,1};

for i = 1:n_build
    % Call of the buildings data

    building_name = name{i,1};

   index = find(ismember(name, building_name));
   el(i) = data{1,5}(index);        % Building annual electricity consumption [kWh]
end

%% Bar graph
close all
building_names = {'BI', 'BS', 'CE' ,'CH' ,'CM', 'GC', 'GR', 'MA', 'ME', 'PH', 'BC', 'CO', 'BP', 'TCV', 'IN', 'ODY', 'AASG', 'EL', 'P0', 'CRPPhb', 'MX', 'BM', 'DIA', 'AI'};
figure
f = bar([1:24], el)
set(gca,'xTick', 1:length(building_names), 'xTickLabel',building_names)
text(1:length(el),el,num2str(el),'vert','bottom','horiz','center'); 

ylabel('Annual electricy demand [kWh]')
xlabel('Building name')



%% Iterations over time graph
close all
tol = load('tol.mat')
tol = tol.ans
plot(tol(100:end))
ylim([-0.1 1e-3])
xlabel('Iterations')
ylabel('Residual')

%% Graph formatting functions
function formatFig(w,h)
fig = gcf;
fig.PaperOrientation = 'landscape';
fig.PaperSize = [w h];
fig.PaperPosition = [0 0 w h];
fig.Renderer = 'Painters'; % for 3D plots
end
function figExport(w,h,name)
global printFlag
formatFig(w,h)
if printFlag == true
    print(gcf, '-dpdf', [pwd '/figures/' name '.pdf']);
end
end

