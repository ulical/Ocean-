clc; clear
run(fullfile(fileparts(fileparts(mfilename('fullpath'))), 'config.m'));

fDIC = cfg.input_08;
fTA  = cfg.input_09;

fT = cfg.input_16;
fS = cfg.input_17;

%% Read grid
lon = double(ncread(fDIC,'lon'));
lat = double(ncread(fDIC,'lat'));

nx = size(lon,1);
ny_grid = size(lon,2);

years = (1850:2014)';
nyear = length(years);

fprintf('Grid size: %d x %d\n',nx,ny_grid);
fprintf('Number of years: %d\n',nyear);

%% Ocean grid-cell area

areaFiles = dir( ...
    cfg.input_18);

if ~isempty(areaFiles)

    fArea = fullfile( ...
        areaFiles(1).folder,areaFiles(1).name);

    area = double(ncread(fArea,'areacello'));

    if ~isequal(size(area),size(lat))
        if isequal(size(area'),size(lat))
            area = area';
        else
            error('areacello dimensions do not match the model grid.');
        end
    end

    fprintf('Using area file: %s\n',fArea);

else

    warning(['CESM2 areacello file not found. ', ...
        'Using cos(latitude) as approximate area weights.']);

    area = cosd(lat);

end

area(~isfinite(area) | area<=0 | area>1e15) = NaN;

%% Constants
rho = 1025;   % kg m^-3, approximate seawater density

% CESM2 noleap calendar: monthly durations
month_days = [31 28 31 30 31 30 ...
              31 31 30 31 30 31];

w = month_days / sum(month_days);
w3 = reshape(w,1,1,12);

%% Preallocate
Rall = nan(nx,ny_grid,nyear,'single');

Rglobal = nan(nyear,1);

for iy = 1:nyear

    yr = years(iy);

    fprintf('Calculating year %d (%d/%d)\n', ...
        yr,iy,nyear);

    DIC_m3 = double(squeeze(ncread( ...
        fDIC,'dissic', ...
        [1 1 1 iy],[nx ny_grid 1 1])));

    TA_m3 = double(squeeze(ncread( ...
        fTA,'talk', ...
        [1 1 1 iy],[nx ny_grid 1 1])));

    DIC_m3(~isfinite(DIC_m3) | abs(DIC_m3)>1e10) = NaN;
    TA_m3(~isfinite(TA_m3) | abs(TA_m3)>1e10) = NaN;

    im0 = (yr-1850)*12 + 1;

    Tmon = double(squeeze(ncread( ...
        fT,'thetao', ...
        [1 1 1 im0],[nx ny_grid 1 12])));

    Smon = double(squeeze(ncread( ...
        fS,'so', ...
        [1 1 1 im0],[nx ny_grid 1 12])));

    Tmon(~isfinite(Tmon) | abs(Tmon)>1e10) = NaN;
    Smon(~isfinite(Smon) | abs(Smon)>1e10) = NaN;

% Day-weighted mean, with missing months renormalized

    denT = sum(double(isfinite(Tmon)).*w3,3);
    denS = sum(double(isfinite(Smon)).*w3,3);

    Tyear = sum(Tmon.*w3,3,'omitnan') ./ denT;
    Syear = sum(Smon.*w3,3,'omitnan') ./ denS;

    Tyear(denT==0) = NaN;
    Syear(denS==0) = NaN;

% D. Unit conversion
% mol m^-3 -> umol kg^-1

    DIC_u = DIC_m3 * 1e6/rho;
    TA_u  = TA_m3  * 1e6/rho;

    valid = isfinite(DIC_u) & ...
            isfinite(TA_u) & ...
            isfinite(Tyear) & ...
            isfinite(Syear) & ...
            isfinite(lat) & abs(lat)<=90 & ...
            DIC_u>0 & TA_u>0 & ...
            Tyear>-5 & Tyear<50 & ...
            Syear>=0 & Syear<50;

% Surface pressure = 0 dbar
% Nutrients set to zero because corresponding
% CESM2 nutrient fields are not included here.

    TA_vec  = TA_u(valid);
    DIC_vec = DIC_u(valid);
    T_vec   = Tyear(valid);
    S_vec   = Syear(valid);

    nvalid = numel(DIC_vec);

    P_vec  = zeros(nvalid,1);
    Si_vec = zeros(nvalid,1);
    PO4_vec = zeros(nvalid,1);

    [RESULT,HEADERS,NICEHEADERS] = CO2SYS( ...
        TA_vec,DIC_vec, ...
        1,2, ...             % TA, DIC
        S_vec, ...
        T_vec,T_vec, ...     % Input/output temperature
        P_vec,P_vec, ...     % Input/output pressure
        Si_vec,PO4_vec, ...
        1, ...               % Total pH scale
        10, ...              % K1/K2 constants
        1);                  % KSO4 constants

    Ryear = nan(nx,ny_grid);

    Ryear(valid) = RESULT(:,14);

    Ryear(~isfinite(Ryear) | Ryear<=0 | Ryear>100) = NaN;

    Rall(:,:,iy) = single(Ryear);

    good = isfinite(Ryear) & ...
           isfinite(area) & area>0;

    if any(good(:))
        Rglobal(iy) = sum(Ryear(good).*area(good)) ...
                    / sum(area(good));
    end

end

fprintf('\nAll years completed.\n');

x = years - mean(years);

n = zeros(nx,ny_grid);
sumX  = zeros(nx,ny_grid);
sumY  = zeros(nx,ny_grid);
sumXX = zeros(nx,ny_grid);
sumXY = zeros(nx,ny_grid);

for iy = 1:nyear

    r = double(Rall(:,:,iy));
    v = isfinite(r);

    r0 = r;
    r0(~v) = 0;

    v = double(v);
    xx = x(iy);

    n     = n     + v;
    sumX  = sumX  + xx*v;
    sumY  = sumY  + r0;
    sumXX = sumXX + xx^2*v;
    sumXY = sumXY + xx*r0;

end

denom = n.*sumXX - sumX.^2;

slope_yr = (n.*sumXY - sumX.*sumY)./denom;

% Require at least 30 valid annual values
slope_yr(n<30 | denom<=0) = NaN;

trend_decade = slope_yr*10;

fprintf('Grid-cell trends calculated.\n');

ok = isfinite(Rglobal);

xg = years(ok);
yg = Rglobal(ok);

p = polyfit(xg,yg,1);

Rglobal_fit = polyval(p,years);

global_trend_decade = p(1)*10;

R2_global = 1 - sum((yg-polyval(p,xg)).^2) ...
    / sum((yg-mean(yg)).^2);

fprintf('\n===== Global surface Revelle factor =====\n');
fprintf('1850-2014 linear trend = %.5f per decade\n', ...
    global_trend_decade);

fprintf('Linear fit R^2 = %.4f\n',R2_global);

fprintf('Fitted change over 164 years = %.4f\n', ...
    p(1)*(2014-1850));

%% Recent period: 1990-2014
recent = ok & years>=1990 & years<=2014;

p_recent = polyfit(years(recent),Rglobal(recent),1);

fprintf('1990-2014 trend = %.5f per decade\n', ...
    p_recent(1)*10);

years = (1850:2014)';

[nx,ny,nt] = size(Rall);

trend_R = nan(nx,ny);      % per year
p_R     = nan(nx,ny);      % significance

for i = 1:nx
    for j = 1:ny

        y = double(squeeze(Rall(i,j,:)));

        valid = ~isnan(y);

% 至少需要大部分年份都有数据
        if sum(valid) >= 100

            x = years(valid);
            yy = y(valid);

            p = polyfit(x,yy,1);

            trend_R(i,j) = p(1);

            yfit = polyval(p,x);
            residual = yy-yfit;

            n = length(yy);

            SSE = sum(residual.^2);

            Sxx = sum((x-mean(x)).^2);

            SE_slope = sqrt( ...
                (SSE/(n-2))/Sxx );

            tvalue = p(1)/SE_slope;

            p_R(i,j) = 2*(1-tcdf(abs(tvalue),n-2));

        end
    end
end

trend_R_decade = trend_R*10;
tmp = trend_R_decade(~isnan(trend_R_decade));

fprintf('Revelle factor trend:\n');
fprintf('min    = %.5f /decade\n',min(tmp));
fprintf('P1     = %.5f /decade\n',prctile(tmp,1));
fprintf('P5     = %.5f /decade\n',prctile(tmp,5));
fprintf('median = %.5f /decade\n',median(tmp));
fprintf('P95    = %.5f /decade\n',prctile(tmp,95));
fprintf('P99    = %.5f /decade\n',prctile(tmp,99));
fprintf('max    = %.5f /decade\n',max(tmp));

lonp = double(lon);
latp = double(lat);

Rp = trend_R_decade;

% find 0/360 longitude jumps
bad = false(size(Rp));

jump_i = abs(diff(lonp,1,1)) > 180;

bad(1:end-1,:) = bad(1:end-1,:) | jump_i;
bad(2:end,:)   = bad(2:end,:)   | jump_i;

jump_j = abs(diff(lonp,1,2)) > 180;

bad(:,1:end-1) = bad(:,1:end-1) | jump_j;
bad(:,2:end)   = bad(:,2:end)   | jump_j;

Rp(bad) = NaN;
lon_close = [lonp; lonp(1,:)];
lat_close = [latp; latp(1,:)];

Rp_close = [Rp; Rp(1,:)];
tmp = Rp(~isnan(Rp));

cmax = prctile(abs(tmp),98);

figure('Position',[100 100 1100 650])

m_proj('miller', ...
    'lon',[0 360], ...
    'lat',[-80 80]);

m_pcolor(lon_close,lat_close,Rp_close);

shading flat
hold on

m_coast( ...
    'patch',[0.80 0.80 0.80], ...
    'edgecolor','k');

sig = p_R < 0.05 & isfinite(trend_R_decade);

% Remove cells around the longitude discontinuity
sig(bad) = false;

step = 8;

sig_plot = false(size(sig));
sig_plot(1:step:end, 1:step:end) = ...
    sig(1:step:end, 1:step:end);

lon_sig = lonp(sig_plot);
lat_sig = latp(sig_plot);

m_plot(lon_sig, lat_sig, 'k.', 'MarkerSize', 4);
m_grid( ...
    'xtick',[0 60 120 180 240 300 360], ...
    'ytick',[-60 -30 0 30 60], ...
    'tickdir','out', ...
    'linestyle',':', ...
    'fontsize',11);

cb = colorbar;

ylabel(cb, ...
    'Revelle factor trend (decade^{-1})')

caxis([0.02 0.13])

title( ...
    'CESM2 Surface Revelle Factor Trend 1850-2014')

set(gca, ...
    'FontName','Times New Roman', ...
    'FontSize',11)

exportgraphics(gcf, ...
    fullfile(cfg.figure_dir, 'CESM2_Revelle_trend_1850_2014 with significance.png'), ...
    'Resolution',300);
