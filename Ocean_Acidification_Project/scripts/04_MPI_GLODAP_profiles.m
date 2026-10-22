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

fDIC1 = cfg.input_10;
fDIC2 = cfg.input_11;

fTA1 = cfg.input_12;
fTA2 = cfg.input_13;

%% grid
lat = double(ncread(fDIC1,'latitude'));
lon = double(ncread(fDIC1,'longitude'));
lev_MPI = double(ncread(fDIC1,'lev'));

lon180 = mod(lon + 180,360) - 180;

%% station coordinates
HOT_lat  = 22.75;
HOT_lon  = -158.00;

BATS_lat = 31.67;
BATS_lon = -64.17;

distHOT = acosd( ...
    sind(HOT_lat).*sind(lat) + ...
    cosd(HOT_lat).*cosd(lat).*cosd(lon180-HOT_lon));

[~,indHOT] = min(distHOT(:));
[iHOT,jHOT] = ind2sub(size(distHOT),indHOT);

fprintf('MPI HOT nearest grid:\n');
fprintf('lat = %.3f, lon = %.3f\n', ...
    lat(iHOT,jHOT),lon180(iHOT,jHOT));

distBATS = acosd( ...
    sind(BATS_lat).*sind(lat) + ...
    cosd(BATS_lat).*cosd(lat).*cosd(lon180-BATS_lon));

[~,indBATS] = min(distBATS(:));
[iBATS,jBATS] = ind2sub(size(distBATS),indBATS);

fprintf('\nMPI BATS nearest grid:\n');
fprintf('lat = %.3f, lon = %.3f\n', ...
    lat(iBATS,jBATS),lon180(iBATS,jBATS));

nz = length(lev_MPI);

DIC_HOT_1 = squeeze(ncread(fDIC1,'dissic', ...
    [iHOT jHOT 1 1],[1 1 nz Inf]));

TA_HOT_1 = squeeze(ncread(fTA1,'talk', ...
    [iHOT jHOT 1 1],[1 1 nz Inf]));

DIC_HOT_2 = squeeze(ncread(fDIC2,'dissic', ...
    [iHOT jHOT 1 1],[1 1 nz Inf]));

TA_HOT_2 = squeeze(ncread(fTA2,'talk', ...
    [iHOT jHOT 1 1],[1 1 nz Inf]));

DIC_HOT_monthly = [double(DIC_HOT_1), double(DIC_HOT_2)];
TA_HOT_monthly  = [double(TA_HOT_1),  double(TA_HOT_2)];

DIC_BATS_1 = squeeze(ncread(fDIC1,'dissic', ...
    [iBATS jBATS 1 1],[1 1 nz Inf]));

TA_BATS_1 = squeeze(ncread(fTA1,'talk', ...
    [iBATS jBATS 1 1],[1 1 nz Inf]));

DIC_BATS_2 = squeeze(ncread(fDIC2,'dissic', ...
    [iBATS jBATS 1 1],[1 1 nz Inf]));

TA_BATS_2 = squeeze(ncread(fTA2,'talk', ...
    [iBATS jBATS 1 1],[1 1 nz Inf]));

DIC_BATS_monthly = [double(DIC_BATS_1), double(DIC_BATS_2)];
TA_BATS_monthly  = [double(TA_BATS_1),  double(TA_BATS_2)];
MPI_HOT_DIC = mean(DIC_HOT_monthly,2,'omitnan');
MPI_HOT_TA  = mean(TA_HOT_monthly,2,'omitnan');

MPI_BATS_DIC = mean(DIC_BATS_monthly,2,'omitnan');
MPI_BATS_TA  = mean(TA_BATS_monthly,2,'omitnan');

rho = 1025;

MPI_HOT_DIC  = MPI_HOT_DIC  * 1e6/rho;
MPI_HOT_TA   = MPI_HOT_TA   * 1e6/rho;
MPI_BATS_DIC = MPI_BATS_DIC * 1e6/rho;
MPI_BATS_TA  = MPI_BATS_TA  * 1e6/rho;
figure('Position',[200 150 650 700])

plot(MPI_HOT_DIC,lev_MPI,'-*','LineWidth',1.8);
hold on
plot(DIC_HOT_obs,z_mid,'+','LineWidth',1.8);
set(gca,'YDir','reverse')

xlabel('DIC (\mumol kg^{-1})')
ylabel('Depth (m)')
title('MPI-ESM1-2-LR DIC profile at HOT')

legend('MPI-ESM1-2-LR','GLODAP','Location','best','fontsize',12)

grid on
box on
set(gca,'FontName','Times New Roman','FontSize',13)

ylim([0 4500])
figure('Position',[200 150 650 700])

plot(MPI_HOT_TA,lev_MPI,'-*','LineWidth',1.8);
hold on
plot(TA_HOT_obs,z_mid,'+','LineWidth',1.8);
set(gca,'YDir','reverse')

xlabel('TALK (\mumol kg^{-1})')
ylabel('Depth (m)')
title('MPI-ESM1-2-LR TALK profile at HOT')

legend('MPI-ESM1-2-LR','GLODAP','Location','best','fontsize',12)

grid on
box on
set(gca,'FontName','Times New Roman','FontSize',13)

ylim([0 4500])
exportgraphics(gcf, ...
    fullfile(cfg.figure_dir, 'MPI-ESM1-2-LR TALK profile at HOT.png'), ...
    'Resolution',300);

figure('Position',[200 150 650 700])

plot(MPI_BATS_DIC,lev_MPI,'-*','LineWidth',1.8);
hold on
plot(DIC_BATS_obs,z_mid,'+','LineWidth',1.8);
set(gca,'YDir','reverse')

xlabel('DIC (\mumol kg^{-1})')
ylabel('Depth (m)')
title('MPI-ESM1-2-LR DIC profile at BATS')

legend('MPI-ESM1-2-LR','GLODAP','Location','best','fontsize',12)

grid on
box on
set(gca,'FontName','Times New Roman','FontSize',13)

ylim([0 4500])
figure('Position',[200 150 650 700])

plot(MPI_BATS_TA,lev_MPI,'-*','LineWidth',1.8);
hold on
plot(TA_BATS_obs,z_mid,'+','LineWidth',1.8);
set(gca,'YDir','reverse')

xlabel('TALK (\mumol kg^{-1})')
ylabel('Depth (m)')
title('MPI-ESM1-2-LR TALK profile at BATS')

legend('MPI-ESM1-2-LR','GLODAP','Location','best','fontsize',12)

grid on
box on
set(gca,'FontName','Times New Roman','FontSize',13)

ylim([0 4500])
exportgraphics(gcf, ...
    fullfile(cfg.figure_dir, 'MPI-ESM1-2-LR TALK profile at BATS.png'), ...
    'Resolution',300);
