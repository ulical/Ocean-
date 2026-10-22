clear
run(fullfile(fileparts(fileparts(mfilename('fullpath'))), 'config.m'));
clc
close all

%% Files
dissic_file = cfg.input_08;
talk_file   = cfg.input_09;

load(fullfile(cfg.processed_dir, 'CESM2_annual_surface_TS_1850_2014.mat'), ...
    'thetao_annual_surface','so_annual_surface','years');

lat = ncread(dissic_file,'lat');
lon = ncread(dissic_file,'lon');

lon180 = mod(lon+180,360)-180;

DIC_m3 = squeeze(ncread(dissic_file,'dissic', ...
    [1 1 1 1], ...
    [Inf Inf 1 Inf]));

TA_m3 = squeeze(ncread(talk_file,'talk', ...
    [1 1 1 1], ...
    [Inf Inf 1 Inf]));

size(DIC_m3)
size(TA_m3)
dic_units = ncreadatt(dissic_file,'dissic','units')
ta_units  = ncreadatt(talk_file,'talk','units')
rho0 = 1025;

DIC = DIC_m3 * 1e6 / rho0;
TA  = TA_m3  * 1e6 / rho0;
iy = find(years==1850);

DIC0 = DIC(:,:,iy);
TA0  = TA(:,:,iy);
T0   = thetao_annual_surface(:,:,iy);
S0   = so_annual_surface(:,:,iy);

valid = ~isnan(DIC0) & ...
        ~isnan(TA0)  & ...
        ~isnan(T0)   & ...
        ~isnan(S0);

dic_vec = double(DIC0(valid));
ta_vec  = double(TA0(valid));
t_vec   = double(T0(valid));
s_vec   = double(S0(valid));

n = length(dic_vec);

pres = zeros(n,1);
si   = zeros(n,1);
po4  = zeros(n,1);
[RESULT,HEADERS,NICEHEADERS] = CO2SYS( ...
    ta_vec, ...
    dic_vec, ...
    1,2, ...          % TA, DIC
    s_vec, ...
    t_vec,t_vec, ...
    pres,pres, ...
    si,po4, ...
    1,10,1);
R1850 = nan(size(DIC0));

R1850(valid) = RESULT(:,14);
iy = find(years==2014);

DIC1 = DIC(:,:,iy);
TA1  = TA(:,:,iy);
T1   = thetao_annual_surface(:,:,iy);
S1   = so_annual_surface(:,:,iy);

valid = ~isnan(DIC1) & ...
        ~isnan(TA1)  & ...
        ~isnan(T1)   & ...
        ~isnan(S1);

dic_vec = double(DIC1(valid));
ta_vec  = double(TA1(valid));
t_vec   = double(T1(valid));
s_vec   = double(S1(valid));

n = length(dic_vec);

pres = zeros(n,1);
si   = zeros(n,1);
po4  = zeros(n,1);

[RESULT,~,~] = CO2SYS( ...
    ta_vec,dic_vec, ...
    1,2, ...
    s_vec, ...
    t_vec,t_vec, ...
    pres,pres, ...
    si,po4, ...
    1,10,1);

R2014 = nan(size(DIC1));

R2014(valid) = RESULT(:,14);
dR = R2014 - R1850;
fprintf('1850 Revelle factor range = %.2f to %.2f\n', ...
    min(R1850,[],'all','omitnan'), ...
    max(R1850,[],'all','omitnan'));

fprintf('2014 Revelle factor range = %.2f to %.2f\n', ...
    min(R2014,[],'all','omitnan'), ...
    max(R2014,[],'all','omitnan'));

fprintf('Delta R range = %.2f to %.2f\n', ...
    min(dR,[],'all','omitnan'), ...
    max(dR,[],'all','omitnan'));
%% ===== Regrid CESM2 curvilinear grid for plotting only =====

lon_plot = mod(lon + 180,360) - 180;
lat_plot = lat;

Rplot = R1850;

ok = ~isnan(lon_plot) & ...
     ~isnan(lat_plot) & ...
     ~isnan(Rplot) & ...
     Rplot > 0 & Rplot < 30;

lon_vec = double(lon_plot(ok));
lat_vec = double(lat_plot(ok));
R_vec   = double(Rplot(ok));

lon_reg = -180:1:180;
lat_reg = -80:1:90;

[LON,LAT] = meshgrid(lon_reg,lat_reg);

F = scatteredInterpolant( ...
    lon_vec,lat_vec,R_vec, ...
    'natural','none');

R1850_reg = F(LON,LAT);

lonp = double(lon);       % 原始 0~360
latp = double(lat);
Rp   = double(R1850);

Rp(isnan(R1850)) = NaN;

%% 找二维网格中所有经度跳变
bad = false(size(Rp));

jump_i = abs(diff(lonp,1,1)) > 180;

bad(1:end-1,:) = bad(1:end-1,:) | jump_i;
bad(2:end,:)   = bad(2:end,:)   | jump_i;

jump_j = abs(diff(lonp,1,2)) > 180;

bad(:,1:end-1) = bad(:,1:end-1) | jump_j;
bad(:,2:end)   = bad(:,2:end)   | jump_j;

% 只把真正跨越0/360的位置切开%
Rp(bad) = NaN;

lon_close = [lonp; lonp(1,:)];
lat_close = [latp; latp(1,:)];
R_close   = [Rp;   Rp(1,:)];
figure('Position',[100 100 1100 650])

m_proj('miller', ...
    'lon',[0 360], ...
    'lat',[-80 80]);

m_pcolor(lonp,latp,Rp);
shading flat

hold on

m_coast('patch',[0.80 0.80 0.80], ...
        'edgecolor','k');

m_grid( ...
    'xtick',[0 60 120 180 240 300 360], ...
    'ytick',[-60 -30 0 30 60], ...
    'tickdir','out', ...
    'linestyle',':', ...
    'box','on', ...
    'fontsize',11);

cb = colorbar;
ylabel(cb,'Revelle factor')

caxis([7 16])

title('CESM2 Surface Revelle Factor, 1850')

set(gca,'FontName','Times New Roman', ...
        'FontSize',11)
figure('Position',[100 100 1100 650])

m_proj('miller', ...
    'lon',[0 360], ...
    'lat',[-80 80]);

m_pcolor(lon_close,lat_close,R_close);
shading flat
hold on

m_coast('patch',[0.80 0.80 0.80], ...
        'edgecolor','k');

m_grid( ...
    'xtick',[0 60 120 180 240 300 360], ...
    'ytick',[-60 -30 0 30 60], ...
    'tickdir','out', ...
    'linestyle',':', ...
    'fontsize',11);

cb = colorbar;
ylabel(cb,'Revelle factor')

caxis([7 16])

title('CESM2 Surface Revelle Factor, 1850')

set(gca,'FontName','Times New Roman', ...
        'FontSize',11)
exportgraphics(gcf,fullfile(cfg.figure_dir, 'CESM2_Revelle_1850.png'),'Resolution',300);

R2014p = double(R2014);
R2014p(bad) = NaN;
R2014_close = [R2014p; R2014p(1,:)];

figure('Position',[100 100 1100 650])

m_proj('miller', ...
    'lon',[0 360], ...
    'lat',[-80 80]);

m_pcolor(lon_close,lat_close,R2014_close);
shading flat
hold on

m_coast('patch',[0.80 0.80 0.80], ...
        'edgecolor','k');

m_grid( ...
    'xtick',[0 60 120 180 240 300 360], ...
    'ytick',[-60 -30 0 30 60], ...
    'tickdir','out', ...
    'linestyle',':', ...
    'fontsize',11);

cb = colorbar;
ylabel(cb,'Revelle factor')

caxis([7 16])

title('CESM2 Surface Revelle Factor, 2014')

set(gca, ...
    'FontName','Times New Roman', ...
    'FontSize',11);

exportgraphics(gcf, ...
    fullfile(cfg.figure_dir, 'CESM2_Revelle_2014.png'), ...
    'Resolution',300);
dR = double(R2014) - double(R1850);
dR(bad) = NaN;
dR_close = [dR; dR(1,:)];
tmp = dR(~isnan(dR));

cmax = prctile(abs(tmp),98);

fprintf('Suggested color limit = +/- %.3f\n',cmax);
figure('Position',[100 100 1100 650])

m_proj('miller', ...
    'lon',[0 360], ...
    'lat',[-80 80]);

levels = linspace(-cmax,cmax,21);

m_pcolor(lon_close,lat_close,dR_close);
shading flat
hold on

m_coast('patch',[0.80 0.80 0.80], ...
        'edgecolor','k');

m_grid( ...
    'xtick',[0 60 120 180 240 300 360], ...
    'ytick',[-60 -30 0 30 60], ...
    'tickdir','out', ...
    'linestyle',':', ...
    'fontsize',11);

cb = colorbar;
ylabel(cb,'\Delta Revelle factor')

caxis([-cmax cmax])

title('CESM2 Change in Surface Revelle Factor (2014 - 1850)')

set(gca, ...
    'FontName','Times New Roman', ...
    'FontSize',11);

exportgraphics(gcf, ...
    fullfile(cfg.figure_dir, 'CESM2_Revelle_change_2014_minus_1850.png'), ...
    'Resolution',300);
lat_mean = mean(lat,1,'omitnan');

dR_zonal = mean(dR,1,'omitnan');

figure
plot(lat_mean,dR_zonal,'k-','LineWidth',1.5)
xlabel('Latitude')
ylabel('Mean \DeltaRevelle factor')
grid on
xlim([-10 10])
