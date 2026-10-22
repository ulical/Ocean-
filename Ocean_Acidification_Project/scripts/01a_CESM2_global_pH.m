clc;clear
run(fullfile(fileparts(fileparts(mfilename('fullpath'))), 'config.m'));
phFile = cfg.input_01;
areaFile = cfg.input_02;

%% Read surface pH only
ph = squeeze(ncread(phFile,'ph', ...
    [1 1 1 1], ...
    [Inf Inf 1 Inf]));

ph(ph > 1e10) = NaN;

%% Read cell area
area = ncread(areaFile,'areacello');

area(area > 1e20) = NaN;
area(area <= 0) = NaN;

%% Check dimensions
disp('Size of ph:')
disp(size(ph))

disp('Size of area:')
disp(size(area))

%% Years
year = (1850:2014)';

%% Global area-weighted mean pH
nt = length(year);
ph_global = nan(nt,1);

for t = 1:nt

    x = ph(:,:,t);

    valid = ~isnan(x) & ~isnan(area);

    ph_global(t) = sum(x(valid).*area(valid)) / ...
                   sum(area(valid));
end

fprintf('Global mean surface pH in 1850 = %.4f\n', ph_global(1));
fprintf('Global mean surface pH in 2014 = %.4f\n', ph_global(end));

delta_pH = ph_global(end) - ph_global(1);

fprintf('Change 2014 - 1850 = %.4f\n', delta_pH);

p = polyfit(year,ph_global,1);

trend_per_year = p(1);
trend_per_decade = p(1)*10;

fprintf('Linear trend = %.6f pH units/year\n', trend_per_year);
fprintf('Linear trend = %.5f pH units/decade\n', trend_per_decade);

figure
plot(year,ph_global,'LineWidth',1.5)

xlabel('Year')
ylabel('Surface pH')
title('CESM2 Global Area-Weighted Surface pH')
grid on

hold on
plot(year,polyval(p,year),'--','LineWidth',1.2)

legend('CESM2','Linear trend','Location','best')
exportgraphics(gcf, ...
    fullfile(cfg.figure_dir, 'CESM2 Global Area-Weighted Surface pH.png'), ...
    'Resolution',300);
ph_cesm2 = ph_global;
save(fullfile(cfg.processed_dir, 'CESM2_surface_pH.mat'),'year','ph_cesm2')

periods = [
    1850 2014
    1900 2014
    1950 2014
    1980 2014
    1990 2014
    2000 2014
];

fprintf('\n=============================================\n')
fprintf('CESM2 global surface pH trends\n')
fprintf('=============================================\n')

for k = 1:size(periods,1)

    y1 = periods(k,1);
    y2 = periods(k,2);

    idx = year >= y1 & year <= y2;

    ptmp = polyfit(year(idx),ph_global(idx),1);

    trend_year = ptmp(1);
    trend_decade = ptmp(1)*10;

    fprintf('%d-%d : % .6f pH/yr   (% .5f pH/decade)\n', ...
        y1,y2,trend_year,trend_decade);

end
