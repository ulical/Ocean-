%% Three-model comparison of global surface pH
clear; clc;
run(fullfile(fileparts(fileparts(mfilename('fullpath'))), 'config.m'));

load(fullfile(cfg.processed_dir, 'CESM2_surface_pH.mat'))
load(fullfile(cfg.processed_dir, 'MPI_surface_pH.mat'))
load(fullfile(cfg.processed_dir, 'IPSL_surface_pH.mat'))

%% Figure
figure('Position',[100 100 950 620])

plot(year,ph_cesm2,'LineWidth',1.8)
hold on

plot(year,ph_mpi,'LineWidth',1.8)
plot(year,ph_ipsl,'LineWidth',1.8)

xlabel('Year','FontSize',14)
ylabel('Global mean surface pH','FontSize',14)

title('CMIP6 Global Area-Weighted Surface Ocean pH', ...
    'FontSize',15,'FontWeight','bold')

legend('CESM2', ...
       'MPI-ESM1-2-LR', ...
       'IPSL-CM6A-LR', ...
       'Location','southwest', ...
       'FontSize',11)

grid on
box on

set(gca, ...
    'FontName','Times New Roman', ...
    'FontSize',12, ...
    'LineWidth',1)

xlim([1850 2014])
exportgraphics(gcf, ...
    fullfile(cfg.figure_dir, 'threemodecomp.png'), ...
    'Resolution',300);
