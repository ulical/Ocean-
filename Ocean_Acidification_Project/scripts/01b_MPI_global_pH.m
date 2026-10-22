%% MPI-ESM1-2-LR historical surface pH
clear; clc;
run(fullfile(fileparts(fileparts(mfilename('fullpath'))), 'config.m'));

phDir = cfg.input_03;

areaFile = fullfile(phDir, ...
    'areacello_Ofx_MPI-ESM1-2-LR_historical_r1i1p1f1_gn.nc');

files = dir(fullfile(phDir, ...
    'ph_Omon_MPI-ESM1-2-LR_historical_r1i1p1f1_gn_*.nc'));

[~,idx] = sort({files.name});
files = files(idx);

fprintf('Number of pH files = %d\n', length(files));

for k = 1:length(files)
    fprintf('%d: %s\n', k, files(k).name);
end

area = ncread(areaFile,'areacello');
area(area > 1e20) = NaN;
area(area <= 0) = NaN;

fprintf('\nSize of areacello:\n')
disp(size(area))

ph_monthly = [];
time_all = [];

for k = 1:length(files)

    file = fullfile(files(k).folder, files(k).name);

    fprintf('Reading %s\n', files(k).name);

    ph_tmp = squeeze(ncread(file,'ph', ...
        [1 1 1 1], ...
        [Inf Inf 1 Inf]));

    ph_tmp(ph_tmp > 1e10) = NaN;

    time_tmp = ncread(file,'time');

    ph_monthly = cat(3, ph_monthly, ph_tmp);
    time_all = [time_all; time_tmp(:)];
end

fprintf('\nSize of complete monthly surface pH:\n')
disp(size(ph_monthly))

fprintf('Number of months = %d\n', size(ph_monthly,3));

nt = size(ph_monthly,3);
ph_global_monthly = nan(nt,1);

for t = 1:nt

    x = ph_monthly(:,:,t);

    valid = ~isnan(x) & ~isnan(area);

    ph_global_monthly(t) = ...
        sum(x(valid).*area(valid)) / sum(area(valid));

end

year = (1850:2014)';
ny = length(year);

if nt ~= ny*12
    error('Expected %d months, but found %d.', ny*12, nt);
end

ph_global_annual = nan(ny,1);

for y = 1:ny

    ind = (y-1)*12 + (1:12);

    ph_global_annual(y) = mean(ph_global_monthly(ind),'omitnan');

end

fprintf('\n=============================================\n')
fprintf('MPI-ESM1-2-LR global surface pH\n')
fprintf('=============================================\n')

fprintf('1850 global mean pH = %.4f\n', ph_global_annual(1));
fprintf('2014 global mean pH = %.4f\n', ph_global_annual(end));

delta_pH = ph_global_annual(end) - ph_global_annual(1);

fprintf('Change 2014 - 1850 = %.4f\n', delta_pH);

p = polyfit(year, ph_global_annual, 1);

fprintf('Linear trend = %.6f pH units/year\n', p(1));
fprintf('Linear trend = %.5f pH units/decade\n', p(1)*10);

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

figure

plot(year,ph_global_annual,'LineWidth',1.5)
hold on
plot(year,polyval(p,year),'--','LineWidth',1.2)

xlabel('Year','FontName','Times New Roman')
ylabel('Surface pH','FontName','Times New Roman')
title('MPI-ESM1-2-LR Global Area-Weighted Surface pH','FontName','Times New Roman')
legend('Annual mean','1850-2014 linear trend','Location','best','FontName','Times New Roman')
grid on
exportgraphics(gcf, ...
    fullfile(cfg.figure_dir, 'MPI_surface_pH_1850_2014.png'), ...
    'Resolution',300);

ph_mpi = ph_global_annual;
save(fullfile(cfg.processed_dir, 'MPI_surface_pH.mat'),'year','ph_mpi');
