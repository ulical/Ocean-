clear
run(fullfile(fileparts(fileparts(mfilename('fullpath'))), 'config.m'));
clc

thetao_file = cfg.input_16;
so_file     = cfg.input_17;

years = (1850:2014)';
ny = length(years);

% CESM2 是 noleap calendar
days_month = [31 28 31 30 31 30 31 31 30 31 30 31];
w = days_month / sum(days_month);

thetao_annual_surface = nan(320,384,ny,'single');
so_annual_surface     = nan(320,384,ny,'single');

for iy = 1:ny

    t0 = (iy-1)*12 + 1;

    fprintf('Processing year %d (%d/%d)\n', ...
        years(iy),iy,ny);

    Tmon = squeeze(ncread(thetao_file,'thetao', ...
        [1 1 1 t0], ...
        [Inf Inf 1 12]));

    Smon = squeeze(ncread(so_file,'so', ...
        [1 1 1 t0], ...
        [Inf Inf 1 12]));

    Tyear = zeros(size(Tmon,1),size(Tmon,2),'single');
    Syear = zeros(size(Smon,1),size(Smon,2),'single');

    WT = zeros(size(Tmon,1),size(Tmon,2),'single');
    WS = zeros(size(Smon,1),size(Smon,2),'single');

    for m = 1:12

        tmpT = Tmon(:,:,m);
        validT = ~isnan(tmpT);

        tmpT(~validT) = 0;

        Tyear = Tyear + tmpT*w(m);
        WT = WT + single(validT)*w(m);

        tmpS = Smon(:,:,m);
        validS = ~isnan(tmpS);

        tmpS(~validS) = 0;

        Syear = Syear + tmpS*w(m);
        WS = WS + single(validS)*w(m);

    end

% 对存在缺月的格点重新归一化
    ok = WT > 0;
    Tyear(ok) = Tyear(ok)./WT(ok);
    Tyear(~ok) = NaN;

    ok = WS > 0;
    Syear(ok) = Syear(ok)./WS(ok);
    Syear(~ok) = NaN;

    thetao_annual_surface(:,:,iy) = Tyear;
    so_annual_surface(:,:,iy)     = Syear;

end
save(fullfile(cfg.processed_dir, 'CESM2_annual_surface_TS_1850_2014.mat'), ...
    'thetao_annual_surface', ...
    'so_annual_surface', ...
    'years', ...
    '-v7.3');
size(thetao_annual_surface)
size(so_annual_surface)

fprintf('1850 SST range = %.2f to %.2f degC\n', ...
    min(thetao_annual_surface(:,:,1),[],'all','omitnan'), ...
    max(thetao_annual_surface(:,:,1),[],'all','omitnan'));

fprintf('1850 SSS range = %.2f to %.2f\n', ...
    min(so_annual_surface(:,:,1),[],'all','omitnan'), ...
    max(so_annual_surface(:,:,1),[],'all','omitnan'));
figure
imagesc(so_annual_surface(:,:,1)')
axis xy
colorbar
title('CESM2 surface salinity, 1850')
S = so_annual_surface(:,:,1);
S = S(~isnan(S));

prctile(S,[0 1 5 50 95 99 100])
