%% IPSL-CM6A-LR historical surface pH
clear; clc;
run(fullfile(fileparts(fileparts(mfilename('fullpath'))), 'config.m'));

phDir = cfg.input_04;

files = dir(fullfile(phDir, ...
    'ph_Omon_IPSL-CM6A-LR_historical_r1i1p1f1_gn_*.nc'));

[~,idx] = sort({files.name});
files = files(idx);

fprintf('Number of files = %d\n',length(files));

%% Read cell area from first file
firstFile = fullfile(files(1).folder,files(1).name);

area = ncread(firstFile,'area');
area(area > 1e20) = NaN;
area(area <= 0) = NaN;

fprintf('Area size:\n')
disp(size(area))

%% Read monthly surface pH
ph_monthly = [];

for k = 1:length(files)

    file = fullfile(files(k).folder,files(k).name);

    fprintf('Reading %s\n',files(k).name);

    ph_tmp = squeeze(ncread(file,'ph', ...
        [1 1 1 1], ...
        [Inf Inf 1 Inf]));

    ph_tmp(ph_tmp > 1e10) = NaN;

    ph_monthly = cat(3,ph_monthly,ph_tmp);

end

fprintf('Monthly surface pH size:\n')
disp(size(ph_monthly))

nt = size(ph_monthly,3);

fprintf('Number of months = %d\n',nt);

%% Area-weighted monthly global mean
ph_global_monthly = nan(nt,1);

for t = 1:nt

    x = ph_monthly(:,:,t);

    valid = ~isnan(x) & ~isnan(area);

    ph_global_monthly(t) = ...
        sum(x(valid).*area(valid)) / sum(area(valid));

end

%% Monthly -> annual
year = (1850:2014)';
ny = length(year);

if nt ~= ny*12
    error('Expected %d months, but found %d.',ny*12,nt);
end

ph_global_annual = nan(ny,1);

for y = 1:ny

    ind = (y-1)*12 + (1:12);

    ph_global_annual(y) = ...
        mean(ph_global_monthly(ind),'omitnan');

end

fprintf('\n====================================\n')
fprintf('IPSL-CM6A-LR global surface pH\n')
fprintf('====================================\n')

fprintf('1850 global mean pH = %.4f\n',ph_global_annual(1));
fprintf('2014 global mean pH = %.4f\n',ph_global_annual(end));

delta_pH = ph_global_annual(end) - ph_global_annual(1);

fprintf('Change 2014 - 1850 = %.4f\n',delta_pH);

p = polyfit(year,ph_global_annual,1);

fprintf('Linear trend = %.6f pH/yr\n',p(1));
fprintf('Linear trend = %.5f pH/decade\n',p(1)*10);

periods = [
    1850 2014
    1900 2014
    1950 2014
    1980 2014
    1990 2014
    2000 2014
];

fprintf('\nSelected-period trends:\n')

for k = 1:size(periods,1)

    y1 = periods(k,1);
    y2 = periods(k,2);

    ind = year >= y1 & year <= y2;

    pp = polyfit(year(ind),ph_global_annual(ind),1);

    fprintf('%d-%d : % .6f pH/yr   (% .5f pH/decade)\n', ...
        y1,y2,pp(1),pp(1)*10);

end

figure('Position',[100 100 900 600])

plot(year,ph_global_annual,'LineWidth',1.8)
hold on

plot(year,polyval(p,year),'--','LineWidth',1.4)

xlabel('Year','FontName','times new roman')
ylabel('Surface pH','FontName','times new roman')

title('IPSL-CM6A-LR Global Area-Weighted Surface pH','FontName','times new roman')

legend('Annual mean','Linear trend','Location','best','FontName','times new roman')

grid on
box on

set(gca, ...
    'FontName','Times New Roman', ...
    'FontSize',12, ...
    'LineWidth',1)
exportgraphics(gcf, ...
    fullfile(cfg.figure_dir, 'IPSL-CM6A-LR Global Area-Weighted Surface pH.png'), ...
    'Resolution',300);
ph_ipsl = ph_global_annual;
save(fullfile(cfg.processed_dir, 'IPSL_surface_pH.mat'),'year','ph_ipsl');
