function results

%% State coefficients [a b c]
coeff_HP_12 = [0.00274976 1.5118 207.932];
coeff_LP_12 = [0.000576456 0.307042 41.0903];
coeff_HP_21 = [0.0042237 2.31092 316.319 ];
coeff_LP_21 = [9.84073E-05 0.039561 3.7957];

%% Data points
HP_12 = [ 0.164742, 0.17837,  0.195036,  0.229345, 0.573749, 0.398792, 0.217625, 0.119554];
LP_12 = [0.273374, 0.28928, 0.282319, 0.364602, 0.461003, 0.388688, 0.307864, 0.253006];

HP_21 = [0.297777, 0.316185, 0.358606, 0.504863, 1.04642,0.709387, 0.397625, 0.216481];
LP_21 = [0.390775, 0.39807, 0.410624, 0.476594, 0.55176, 0.505498, 0.432792, 0.366478];

Text = [4.6, 5, 6,  9.1, 14.4, 11.5, 6.6, 2.1];
Text = Text + 273

%% Define quadratic functions
f = @(a, b, c, x) a*x*x-b*x+c;
quad_HP_12 = generate_quadratic(coeff_HP_12, f)
quad_LP_12 = generate_quadratic(coeff_LP_12, f)
quad_HP_21 = generate_quadratic(coeff_HP_21, f)
quad_LP_21 = generate_quadratic(coeff_LP_21, f)

titles = ["HP_12", "LP_12", "HP_21", "LP_21"];


%% Plot each graph

plot_regression(Text, titles(1), quad_HP_12, HP_12) 
plot_regression(Text, titles(2), quad_LP_12, LP_12) 
plot_regression(Text, titles(3), quad_HP_21, HP_21) 
plot_regression(Text, titles(4), quad_LP_21, LP_21) 
%g = generate_quadratic(coeff_HP_12, f)

%% Generation of graphs for: data point vs regressed point

for i = 1:8
corr_HP_12(i) = quad_HP_12(Text(i))
corr_LP_12(i) = quad_LP_12(Text(i))
corr_HP_21(i) = quad_HP_21(Text(i))
corr_LP_21(i) = quad_LP_21(Text(i))
end

titles = ["corr_HP_12", "corr_LP_12", "corr_HP_21", "corr_LP_21"];

plot_correlation(titles(1), HP_12, corr_HP_12) 
plot_correlation(titles(2), LP_12, corr_LP_12) 
plot_correlation(titles(3), HP_21, corr_HP_21) 
plot_correlation(titles(4), LP_21, corr_LP_21) 

%% Graph for all other fluids
plot_all_fluids(f, Text)
end

function plot_all_fluids(f, Text)

% State coefficients
coeff_HP_20 = [0.00255438 1.39412 190.358];
coeff_HP_30 = [0.00270757 1.4653 198.516]
coeff_HP_40 = [0.0026193 1.41759 192.048];

coeff_LP_20 = [0.000284124 0.139853 17.4208];
coeff_LP_30 = [0.00105432 0.569855 77.4214];
coeff_LP_40 = [0.00101758 0.549892 74.6889];


% Generate quadratic functions
quad_HP_20 = generate_quadratic(coeff_HP_20, f)
quad_HP_30 = generate_quadratic(coeff_HP_30, f)
quad_HP_40 = generate_quadratic(coeff_HP_40, f)
quad_LP_20 = generate_quadratic(coeff_LP_20, f)
quad_LP_30 = generate_quadratic(coeff_LP_30, f)
quad_LP_40 = generate_quadratic(coeff_LP_40, f)


all_fluids = fplot(quad_HP_20, [min(Text), max(Text)])
hold on;
fplot(quad_HP_30, [min(Text), max(Text)])
fplot(quad_HP_40, [min(Text), max(Text)])
fplot(quad_LP_20, [min(Text), max(Text)])
fplot(quad_LP_30, [min(Text), max(Text)])
fplot(quad_LP_40, [min(Text), max(Text)])

hold off

xlim([min(Text), max(Text)])
xlabel('External Temperature [C]')
ylabel('Carnot factor')
legend('HP_{20}', 'HP_{30}', 'HP_{40}', 'LP_{20}', 'LP_{30}', 'LP_{40}', 'Location', 'northwest')

figExport(5, 4, 'all_fluids')



end


function plot_correlation (title, data1, data2)

lin = @(x) x
plot = fplot(lin, [min(data1)-0.05, max(data1)+0.05], 'blue')
hold on
scatter(data1, data2, 'filled', 'MarkerFaceColor', 'red')

hold off

xlabel('Experimental Carnot factor')
ylabel('Regressed Carnot factor')
legend('Regression', 'Data', 'Location', 'northwest')
figExport(5, 4, title.char)
end

function plot_regression (Text, title, g, data)
plot = fplot(g, [min(Text), max(Text)], 'blue')
hold on
scatter(Text, data, 'filled', 'MarkerFaceColor', 'red')

hold off
xlabel('External Temperature [C]')
ylabel('Carnot factor')
legend('Regression', 'Data', 'Location', 'northwest')
figExport(5, 4, title.char)
end

function fn = generate_quadratic(arr, f)
fn = @(x) f(arr(1), arr(2), arr(3), x)
end


function figExport(w,h,name)
fig = gcf;
fig.PaperOrientation = 'landscape';
fig.PaperSize = [w h];
fig.PaperPosition = [0 0 w h];
% fig.Renderer = 'Painters'; % for 3D plots
print(gcf, '-dpdf', [pwd '/figures/' name '.pdf']);
end