run(fullfile(fileparts(fileparts(mfilename('fullpath'))), 'config.m'));
clc

fDIC = cfg.input_08;
fTA  = cfg.input_09;
fPH  = cfg.input_01;

fT = cfg.input_16;
fS = cfg.input_17;

lon = double(ncread(fDIC,'lon'));
lat = double(ncread(fDIC,'lat'));

DIC2014 = squeeze(ncread(fDIC,'dissic', ...
    [1 1 1 165],[Inf Inf 1 1]));

TA2014 = squeeze(ncread(fTA,'talk', ...
    [1 1 1 165],[Inf Inf 1 1]));

PH_model2014 = squeeze(ncread(fPH,'ph', ...
    [1 1 1 165],[Inf Inf 1 1]));

DIC2014 = double(DIC2014);
TA2014  = double(TA2014);
PH_model2014 = double(PH_model2014);

im0 = (2014-1850)*12 + 1;

T2014_mon = squeeze(ncread(fT,'thetao', ...
    [1 1 1 im0],[Inf Inf 1 12]));

S2014_mon = squeeze(ncread(fS,'so', ...
    [1 1 1 im0],[Inf Inf 1 12]));

T2014_mon = double(T2014_mon);
S2014_mon = double(S2014_mon);

% CESM2 noleap calendar
month_days = [31 28 31 30 31 30 31 31 30 31 30 31];
w = month_days / sum(month_days);

T2014 = zeros(size(T2014_mon,1),size(T2014_mon,2));
S2014 = zeros(size(S2014_mon,1),size(S2014_mon,2));

for m = 1:12
    T2014 = T2014 + T2014_mon(:,:,m)*w(m);
    S2014 = S2014 + S2014_mon(:,:,m)*w(m);
end
% Unit conversion
% mol m^-3 -> umol kg^-1

rho = 1025;

DIC_u = DIC2014 * 1e6/rho;
TA_u  = TA2014  * 1e6/rho;

valid = ...
    ~isnan(DIC_u) & ...
    ~isnan(TA_u) & ...
    ~isnan(T2014) & ...
    ~isnan(S2014);

TA_vec  = TA_u(valid);
DIC_vec = DIC_u(valid);
T_vec   = T2014(valid);
S_vec   = S2014(valid);

n = length(TA_vec);

% surface pressure ~ 0 dbar
P_vec = zeros(n,1);

% nutrients set to zero
Si_vec  = zeros(n,1);
PO4_vec = zeros(n,1);

[RESULT,HEADERS,NICEHEADERS] = CO2SYS( ...
    TA_vec, ...
    DIC_vec, ...
    1, ...          % TA
    2, ...          % DIC
    S_vec, ...
    T_vec, ...
    T_vec, ...
    P_vec, ...
    P_vec, ...
    Si_vec, ...
    PO4_vec, ...
    1, ...          % Total pH scale
    10, ...         % K1/K2 constants
    1);             % KSO4

PH_calc2014 = nan(size(DIC_u));

PH_calc2014(valid) = RESULT(:,3);

dPH2014 = PH_calc2014 - PH_model2014;

tmp = dPH2014(~isnan(dPH2014));

fprintf('\n===== 2014 global surface pH self-consistency =====\n');
fprintf('Mean bias = %.5f\n',mean(tmp,'omitnan'));
fprintf('Mean abs bias = %.5f\n',mean(abs(tmp),'omitnan'));
fprintf('RMSE = %.5f\n',sqrt(mean(tmp.^2,'omitnan')));
fprintf('Min bias = %.5f\n',min(tmp));
fprintf('Max bias = %.5f\n',max(tmp));
% Mask 0/360 longitude seam for plotting

lonp = double(lon);
latp = double(lat);

bad = false(size(lonp));

jump_i = abs(diff(lonp,1,1)) > 180;

bad(1:end-1,:) = bad(1:end-1,:) | jump_i;
bad(2:end,:)   = bad(2:end,:)   | jump_i;

jump_j = abs(diff(lonp,1,2)) > 180;

bad(:,1:end-1) = bad(:,1:end-1) | jump_j;
bad(:,2:end)   = bad(:,2:end)   | jump_j;

PH_model_plot = PH_model2014;
PH_calc_plot  = PH_calc2014;
dPH_plot      = dPH2014;

% 把跨越 0/360 的位置切开
PH_model_plot(bad) = NaN;
PH_calc_plot(bad)  = NaN;
dPH_plot(bad)      = NaN;

lon_close = [lonp; lonp(1,:)];
lat_close = [latp; latp(1,:)];

PH_model_close = [PH_model_plot; PH_model_plot(1,:)];
PH_calc_close  = [PH_calc_plot;  PH_calc_plot(1,:)];
dPH_close      = [dPH_plot;      dPH_plot(1,:)];

figure('Position',[100 100 1100 650])

m_proj('miller','lon',[0 360],'lat',[-80 80]);

m_pcolor(lon_close,lat_close,PH_model_close);
shading flat
hold on

m_coast('patch',[0.80 0.80 0.80],'edgecolor','k');

m_grid( ...
    'xtick',[0 60 120 180 240 300 360], ...
    'ytick',[-60 -30 0 30 60], ...
    'tickdir','out', ...
    'linestyle',':', ...
    'fontsize',11);

cb = colorbar;
ylabel(cb,'pH')

caxis([7.8 8.2])

title('CESM2 Surface pH, 2014')

set(gca,'FontName','Times New Roman','FontSize',11)

exportgraphics(gcf, ...
    fullfile(cfg.figure_dir, 'CESM2_surface_pH_2014.png'), ...
    'Resolution',300);

figure('Position',[100 100 1100 650])

m_proj('miller','lon',[0 360],'lat',[-80 80]);

m_pcolor(lon_close,lat_close,PH_calc_close);
shading flat
hold on

m_coast('patch',[0.80 0.80 0.80],'edgecolor','k');

m_grid( ...
    'xtick',[0 60 120 180 240 300 360], ...
    'ytick',[-60 -30 0 30 60], ...
    'tickdir','out', ...
    'linestyle',':', ...
    'fontsize',11);

cb = colorbar;
ylabel(cb,'pH')

caxis([7.8 8.2])

title('CO2SYS Reconstructed Surface pH, 2014')

set(gca,'FontName','Times New Roman','FontSize',11)

exportgraphics(gcf, ...
    fullfile(cfg.figure_dir, 'CESM2_surface_pH_CO2SYS_2014.png'), ...
    'Resolution',300);

tmp = dPH2014(~isnan(dPH2014));

cmax = prctile(abs(tmp),98);

figure('Position',[100 100 1100 650])

m_proj('miller','lon',[0 360],'lat',[-80 80]);

m_pcolor(lon_close,lat_close,dPH_close);
shading flat
hold on

m_coast('patch',[0.80 0.80 0.80],'edgecolor','k');

m_grid( ...
    'xtick',[0 60 120 180 240 300 360], ...
    'ytick',[-60 -30 0 30 60], ...
    'tickdir','out', ...
    'linestyle',':', ...
    'fontsize',11);

cb = colorbar;
ylabel(cb,'pH_{CO2SYS} - pH_{CESM2}')

caxis([-cmax cmax])

title('Surface pH Reconstruction Bias, 2014')

set(gca,'FontName','Times New Roman','FontSize',11)

exportgraphics(gcf, ...
    fullfile(cfg.figure_dir, 'CESM2_surface_pH_bias_2014.png'), ...
    'Resolution',300);
