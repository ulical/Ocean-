run(fullfile(fileparts(fileparts(mfilename('fullpath'))), 'config.m'));
clc

%% files
fDIC = cfg.input_08;
fTA  = cfg.input_09;
fPH  = cfg.input_01;

fT = cfg.input_16;
fS = cfg.input_17;

%% grid
lon = double(ncread(fDIC,'lon'));
lat = double(ncread(fDIC,'lat'));

lon180 = mod(lon+180,360)-180;

%% stations
HOT_lat  = 22.75;
HOT_lon  = -158.00;

BATS_lat = 31.67;
BATS_lon = -64.17;

%% nearest HOT
distHOT = acosd( ...
    sind(HOT_lat).*sind(lat) + ...
    cosd(HOT_lat).*cosd(lat).*cosd(lon180-HOT_lon));

[~,indHOT] = min(distHOT(:));
[iHOT,jHOT] = ind2sub(size(distHOT),indHOT);

%% nearest BATS
distBATS = acosd( ...
    sind(BATS_lat).*sind(lat) + ...
    cosd(BATS_lat).*cosd(lat).*cosd(lon180-BATS_lon));

[~,indBATS] = min(distBATS(:));
[iBATS,jBATS] = ind2sub(size(distBATS),indBATS);

iy0 = 1990-1850+1;
ny  = 25;

DIC_HOT = squeeze(ncread(fDIC,'dissic', ...
    [iHOT jHOT 1 iy0],[1 1 1 ny]));

TA_HOT = squeeze(ncread(fTA,'talk', ...
    [iHOT jHOT 1 iy0],[1 1 1 ny]));

PH_HOT_model = squeeze(ncread(fPH,'ph', ...
    [iHOT jHOT 1 iy0],[1 1 1 ny]));

DIC_BATS = squeeze(ncread(fDIC,'dissic', ...
    [iBATS jBATS 1 iy0],[1 1 1 ny]));

TA_BATS = squeeze(ncread(fTA,'talk', ...
    [iBATS jBATS 1 iy0],[1 1 1 ny]));

PH_BATS_model = squeeze(ncread(fPH,'ph', ...
    [iBATS jBATS 1 iy0],[1 1 1 ny]));

im0 = (1990-1850)*12 + 1;
nm  = 25*12;

T_HOT_mon = squeeze(ncread(fT,'thetao', ...
    [iHOT jHOT 1 im0],[1 1 1 nm]));

S_HOT_mon = squeeze(ncread(fS,'so', ...
    [iHOT jHOT 1 im0],[1 1 1 nm]));

T_BATS_mon = squeeze(ncread(fT,'thetao', ...
    [iBATS jBATS 1 im0],[1 1 1 nm]));

S_BATS_mon = squeeze(ncread(fS,'so', ...
    [iBATS jBATS 1 im0],[1 1 1 nm]));
month_days = [31 28 31 30 31 30 31 31 30 31 30 31];
w = month_days/sum(month_days);

T_HOT_yr  = nan(ny,1);
S_HOT_yr  = nan(ny,1);
T_BATS_yr = nan(ny,1);
S_BATS_yr = nan(ny,1);

for iy = 1:ny

    ind = (iy-1)*12 + (1:12);

    T_HOT_yr(iy)  = sum(double(T_HOT_mon(ind)).*w');
    S_HOT_yr(iy)  = sum(double(S_HOT_mon(ind)).*w');

    T_BATS_yr(iy) = sum(double(T_BATS_mon(ind)).*w');
    S_BATS_yr(iy) = sum(double(S_BATS_mon(ind)).*w');

end
% mol m^-3 -> umol kg^-1
rho = 1025;

DIC_HOT_u = double(DIC_HOT)*1e6/rho;
TA_HOT_u  = double(TA_HOT)*1e6/rho;

DIC_BATS_u = double(DIC_BATS)*1e6/rho;
TA_BATS_u  = double(TA_BATS)*1e6/rho;

% surface pressure ~ 0 dbar

P = zeros(ny,1);

[RESULT_HOT,~,~] = CO2SYS( ...
    TA_HOT_u,DIC_HOT_u, ...
    1,2, ...
    S_HOT_yr,T_HOT_yr,T_HOT_yr, ...
    P,P, ...
    zeros(ny,1),zeros(ny,1), ...
    1,10,1);

PH_HOT_calc = RESULT_HOT(:,3);

[RESULT_BATS,~,~] = CO2SYS( ...
    TA_BATS_u,DIC_BATS_u, ...
    1,2, ...
    S_BATS_yr,T_BATS_yr,T_BATS_yr, ...
    P,P, ...
    zeros(ny,1),zeros(ny,1), ...
    1,10,1);

PH_BATS_calc = RESULT_BATS(:,3);

years = (1990:2014)';

bias_HOT  = PH_HOT_calc  - double(PH_HOT_model);
bias_BATS = PH_BATS_calc - double(PH_BATS_model);

fprintf('HOT mean bias = %.4f\n',mean(bias_HOT,'omitnan'));
fprintf('HOT RMSE      = %.4f\n',sqrt(mean(bias_HOT.^2,'omitnan')));

fprintf('BATS mean bias = %.4f\n',mean(bias_BATS,'omitnan'));
fprintf('BATS RMSE      = %.4f\n',sqrt(mean(bias_BATS.^2,'omitnan')));

figure

plot(years,PH_HOT_model,'k-','LineWidth',1.8)
hold on
plot(years,PH_HOT_calc,'r--','LineWidth',1.8)

xlabel('Year')
ylabel('Surface pH')
title('CESM2 surface pH self-consistency at HOT')

legend('CESM2 ph','CO2SYS reconstructed pH')
set(gca,"FontName","times new roman","fontsize",16)
grid on
box on
exportgraphics(gcf, ...
    fullfile(cfg.figure_dir, 'CESM2 surface pH self-consistency at HOT.png'), ...
    'Resolution',300);
