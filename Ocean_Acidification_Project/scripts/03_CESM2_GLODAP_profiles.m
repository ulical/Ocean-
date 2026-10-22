clc;clear
run(fullfile(fileparts(fileparts(mfilename('fullpath'))), 'config.m'));
file_glodap = cfg.input_07;

load(file_glodap, ...
    'latitude','longitude','depth','year','tco2','talk');
size(latitude)
size(longitude)
size(depth)
size(tco2)
size(talk)
lon = mod(longitude + 180,360) - 180;
lat = latitude;
z   = depth;

DIC_glodap = tco2;
TA_glodap  = talk;
HOT_lat = 22.75;
HOT_lon = -158.00;

BATS_lat = 31.67;
BATS_lon = -64.17;
R = 6371;   % Earth radius, km

%% HOT distance
dist_HOT = 2*R*asin(sqrt( ...
    sind((lat-HOT_lat)/2).^2 + ...
    cosd(lat).*cosd(HOT_lat).* ...
    sind((lon-HOT_lon)/2).^2 ));

%% BATS distance
dist_BATS = 2*R*asin(sqrt( ...
    sind((lat-BATS_lat)/2).^2 + ...
    cosd(lat).*cosd(BATS_lat).* ...
    sind((lon-BATS_lon)/2).^2 ));
idx_HOT = dist_HOT <= 200 & ...
          ~isnan(z) & ...
          ~isnan(DIC_glodap) & ...
          ~isnan(TA_glodap);

idx_BATS = dist_BATS <= 200 & ...
           ~isnan(z) & ...
           ~isnan(DIC_glodap) & ...
           ~isnan(TA_glodap);

fprintf('HOT GLODAP samples = %d\n',sum(idx_HOT));
fprintf('BATS GLODAP samples = %d\n',sum(idx_BATS));
idx_HOT_9214 = idx_HOT & year >= 1992 & year <= 2014;
idx_BATS_9214 = idx_BATS & year >= 1992 & year <= 2014;

fprintf('HOT 1992-2014 samples = %d\n',sum(idx_HOT_9214));
fprintf('BATS 1992-2014 samples = %d\n',sum(idx_BATS_9214));
fprintf('HOT max depth = %.1f m\n',max(z(idx_HOT_9214),[],'omitnan'));
fprintf('BATS max depth = %.1f m\n',max(z(idx_BATS_9214),[],'omitnan'));
%% 深度分箱
z_edges = [0 25 50 75 100 150 200 300 400 500 ...
           750 1000 1500 2000 3000 4000 5000];

z_mid = (z_edges(1:end-1) + z_edges(2:end))/2;
z_hot   = z(idx_HOT_9214);
dic_hot = DIC_glodap(idx_HOT_9214);
ta_hot  = TA_glodap(idx_HOT_9214);

DIC_HOT_obs = nan(size(z_mid));
TA_HOT_obs  = nan(size(z_mid));
N_HOT       = zeros(size(z_mid));

for k = 1:length(z_mid)

    ii = z_hot >= z_edges(k) & ...
         z_hot <  z_edges(k+1);

    N_HOT(k) = sum(ii);

    if N_HOT(k) > 0
        DIC_HOT_obs(k) = mean(dic_hot(ii),'omitnan');
        TA_HOT_obs(k)  = mean(ta_hot(ii),'omitnan');
    end
end
z_bats   = z(idx_BATS_9214);
dic_bats = DIC_glodap(idx_BATS_9214);
ta_bats  = TA_glodap(idx_BATS_9214);

DIC_BATS_obs = nan(size(z_mid));
TA_BATS_obs  = nan(size(z_mid));
N_BATS       = zeros(size(z_mid));

for k = 1:length(z_mid)

    ii = z_bats >= z_edges(k) & ...
         z_bats <  z_edges(k+1);

    N_BATS(k) = sum(ii);

    if N_BATS(k) > 0
        DIC_BATS_obs(k) = mean(dic_bats(ii),'omitnan');
        TA_BATS_obs(k)  = mean(ta_bats(ii),'omitnan');
    end
end
HOT_table = table( ...
    z_mid',N_HOT',DIC_HOT_obs',TA_HOT_obs', ...
    'VariableNames',{'Depth_mid','N','DIC','TA'});

BATS_table = table( ...
    z_mid',N_BATS',DIC_BATS_obs',TA_BATS_obs', ...
    'VariableNames',{'Depth_mid','N','DIC','TA'});

disp(HOT_table)
disp(BATS_table)

file_dic = cfg.input_08;
file_ta  = cfg.input_09;

latm = ncread(file_dic,'lat');
lonm = ncread(file_dic,'lon');

lonm = mod(lonm + 180,360) - 180;

R = 6371;

HOT_lat  = 22.75;
HOT_lon  = -158.00;

BATS_lat = 31.67;
BATS_lon = -64.17;

%% HOT
dist = 2*R*asin(sqrt( ...
    sind((latm-HOT_lat)/2).^2 + ...
    cosd(latm).*cosd(HOT_lat).* ...
    sind((lonm-HOT_lon)/2).^2 ));

[dmin_HOT,ind] = min(dist(:));
[iHOT,jHOT] = ind2sub(size(dist),ind);

fprintf('\nCESM2 HOT nearest grid:\n');
fprintf('lat = %.3f\n',latm(iHOT,jHOT));
fprintf('lon = %.3f\n',lonm(iHOT,jHOT));
fprintf('distance = %.1f km\n',dmin_HOT);

%% BATS
dist = 2*R*asin(sqrt( ...
    sind((latm-BATS_lat)/2).^2 + ...
    cosd(latm).*cosd(BATS_lat).* ...
    sind((lonm-BATS_lon)/2).^2 ));

[dmin_BATS,ind] = min(dist(:));
[iBATS,jBATS] = ind2sub(size(dist),ind);

fprintf('\nCESM2 BATS nearest grid:\n');
fprintf('lat = %.3f\n',latm(iBATS,jBATS));
fprintf('lon = %.3f\n',lonm(iBATS,jBATS));
fprintf('distance = %.1f km\n',dmin_BATS);
info = ncinfo(file_dic,'dissic');

nz = info.Size(3);
nt = info.Size(4);

DIC_HOT_raw = squeeze(ncread(file_dic,'dissic', ...
    [iHOT jHOT 1 1], ...
    [1 1 nz nt]));

TA_HOT_raw = squeeze(ncread(file_ta,'talk', ...
    [iHOT jHOT 1 1], ...
    [1 1 nz nt]));

DIC_BATS_raw = squeeze(ncread(file_dic,'dissic', ...
    [iBATS jBATS 1 1], ...
    [1 1 nz nt]));

TA_BATS_raw = squeeze(ncread(file_ta,'talk', ...
    [iBATS jBATS 1 1], ...
    [1 1 nz nt]));
years_model = (1850:2014)';

it = years_model >= 1992 & years_model <= 2014;

DIC_HOT_model = mean(DIC_HOT_raw(:,it),2,'omitnan');
TA_HOT_model  = mean(TA_HOT_raw(:,it),2,'omitnan');

DIC_BATS_model = mean(DIC_BATS_raw(:,it),2,'omitnan');
TA_BATS_model  = mean(TA_BATS_raw(:,it),2,'omitnan');
lev = ncread(file_dic,'lev');

% CESM2 lev 单位是 cm
z_CESM2 = lev / 100;
rho0 = 1025;

DIC_HOT_model = DIC_HOT_model * 1e6 / rho0;
TA_HOT_model  = TA_HOT_model  * 1e6 / rho0;

DIC_BATS_model = DIC_BATS_model * 1e6 / rho0;
TA_BATS_model  = TA_BATS_model  * 1e6 / rho0;
fprintf('\nCESM2 HOT:\n');
fprintf('surface DIC = %.1f umol/kg\n',DIC_HOT_model(1));
fprintf('surface TA  = %.1f umol/kg\n',TA_HOT_model(1));

fprintf('\nCESM2 BATS:\n');
fprintf('surface DIC = %.1f umol/kg\n',DIC_BATS_model(1));
fprintf('surface TA  = %.1f umol/kg\n',TA_BATS_model(1));

fprintf('\nCESM2 deep values:\n');
fprintf('HOT deepest DIC = %.1f, TA = %.1f\n', ...
    DIC_HOT_model(end),TA_HOT_model(end));

fprintf('BATS deepest DIC = %.1f, TA = %.1f\n', ...
    DIC_BATS_model(end),TA_BATS_model(end));
figure('Position',[200 150 650 700])

plot(DIC_HOT_model,z_CESM2,'-o','LineWidth',1.8);
hold on
plot(DIC_HOT_obs,z_mid,'ks','MarkerFaceColor','w','LineWidth',1.5);

set(gca,'YDir','reverse')

xlabel('DIC (\mumol kg^{-1})')
ylabel('Depth (m)')
title('DIC profile at HOT')

legend('CESM2','GLODAP','Location','best')

grid on
box on
set(gca,'FontName','Times New Roman','FontSize',12)

ylim([0 4500])
exportgraphics(gcf, ...
    fullfile(cfg.figure_dir, 'DIC profile at HOT.png'), ...
    'Resolution',300);
figure('Position',[200 150 650 700])

plot(TA_HOT_model,z_CESM2,'-o','LineWidth',1.8);
hold on
plot(TA_HOT_obs,z_mid,'ks','MarkerFaceColor','w','LineWidth',1.5);

set(gca,'YDir','reverse')

xlabel('Total alkalinity (\mumol kg^{-1})')
ylabel('Depth (m)')
title('Total alkalinity profile at HOT')

legend('CESM2','GLODAP','Location','best')

grid on
box on
set(gca,'FontName','Times New Roman','FontSize',12)

ylim([0 4500])
exportgraphics(gcf, ...
    fullfile(cfg.figure_dir, 'Total alkalinity profile at HOT.png'), ...
    'Resolution',300);

figure('Position',[200 150 650 700])

plot(DIC_BATS_model,z_CESM2,'-o','LineWidth',1.8);
hold on

plot(DIC_BATS_obs,z_mid,'ks', ...
    'MarkerFaceColor','w', ...
    'LineWidth',1.5);

set(gca,'YDir','reverse')

xlabel('DIC (\mumol kg^{-1})')
ylabel('Depth (m)')
title('DIC profile at BATS')

legend('CESM2','GLODAP','Location','best')

grid on
box on

set(gca, ...
    'FontName','Times New Roman', ...
    'FontSize',12)

ylim([0 5000])
exportgraphics(gcf,fullfile(cfg.figure_dir, 'BATS_DIC_CESM2_GLODAP.png'),'Resolution',300)

figure('Position',[200 150 650 700])

plot(TA_BATS_model,z_CESM2,'-o','LineWidth',1.8);
hold on

plot(TA_BATS_obs,z_mid,'ks', ...
    'MarkerFaceColor','w', ...
    'LineWidth',1.5);

set(gca,'YDir','reverse')

xlabel('Total alkalinity (\mumol kg^{-1})')
ylabel('Depth (m)')
title('Total alkalinity profile at BATS')

legend('CESM2','GLODAP','Location','best')

grid on
box on

set(gca, ...
    'FontName','Times New Roman', ...
    'FontSize',12)

ylim([0 5000])
exportgraphics(gcf,fullfile(cfg.figure_dir, 'BATS_TA_CESM2_GLODAP.png'),'Resolution',300)
