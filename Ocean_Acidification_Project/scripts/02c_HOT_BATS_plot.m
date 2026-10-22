clc;clear
run(fullfile(fileparts(fileparts(mfilename('fullpath'))), 'config.m'));
load(fullfile(cfg.processed_dir, 'BATS_pH.mat'));
load(fullfile(cfg.processed_dir, 'HOT_pH.mat'));
%% HOT vs BATS surface pH trends

p_hot  = polyfit(Year_HOT,  pH_HOT,  1);
p_bats = polyfit(Year_BATS, pH_BATS, 1);

fit_hot  = polyval(p_hot, Year_HOT);
fit_bats = polyval(p_bats,Year_BATS);

figure('Position',[200 150 900 600]);

plot(Year_HOT,pH_HOT,'o-','LineWidth',1.5,...
    'MarkerSize',5);
hold on

plot(Year_BATS,pH_BATS,'s-','LineWidth',1.5,...
    'MarkerSize',5);

plot(Year_HOT,fit_hot,'--','LineWidth',2);
plot(Year_BATS,fit_bats,'--','LineWidth',2);

xlabel('Year','FontSize',14);
ylabel('Surface pH','FontSize',14);

title('Surface Ocean pH Trends at HOT and BATS',...
    'FontSize',15);

legend( ...
    'HOT annual mean', ...
    'BATS annual mean', ...
    sprintf('HOT trend = %.4f yr^{-1}',p_hot(1)), ...
    sprintf('BATS trend = %.4f yr^{-1}',p_bats(1)), ...
    'Location','best');

grid on
box on

set(gca,...
    'FontName','Times New Roman',...
    'FontSize',12,...
    'LineWidth',1);

xlim([1991 2015]);

%% 保存
exportgraphics(gcf,fullfile(cfg.figure_dir, 'HOT_BATS_pH_trend.png'),'Resolution',300);
exportgraphics(gcf,fullfile(cfg.figure_dir, 'HOT_BATS_pH_trend.pdf'),'ContentType','vector');
anom_HOT  = pH_HOT  - pH_HOT(1);
anom_BATS = pH_BATS - pH_BATS(1);

figure('Position',[200 150 900 600]);

plot(Year_HOT,anom_HOT,'o-','LineWidth',1.8,...
    'MarkerSize',5);
hold on

plot(Year_BATS,anom_BATS,'s-','LineWidth',1.8,...
    'MarkerSize',5);

p1 = polyfit(Year_HOT,anom_HOT,1);
p2 = polyfit(Year_BATS,anom_BATS,1);

plot(Year_HOT,polyval(p1,Year_HOT),'--','LineWidth',2);
plot(Year_BATS,polyval(p2,Year_BATS),'--','LineWidth',2);

xlabel('Year','FontSize',14);
ylabel('\Delta pH relative to first year','FontSize',14);

title('Surface pH Change at HOT and BATS',...
    'FontSize',15);

legend( ...
    'HOT', ...
    'BATS', ...
    sprintf('HOT: %.4f yr^{-1}',p1(1)), ...
    sprintf('BATS: %.4f yr^{-1}',p2(1)), ...
    'Location','southwest');

yline(0,':');

grid on
box on

set(gca,...
    'FontName','Times New Roman',...
    'FontSize',12,...
    'LineWidth',1);

xlim([1991 2015]);

exportgraphics(gcf,fullfile(cfg.figure_dir, 'HOT_BATS_pH_anomaly.png'),'Resolution',300);
exportgraphics(gcf,fullfile(cfg.figure_dir, 'HOT_BATS_pH_anomaly.pdf'),'ContentType','vector');
