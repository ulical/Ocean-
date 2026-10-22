clc;clear
run(fullfile(fileparts(fileparts(mfilename('fullpath'))), 'config.m'));
%% Read HOT data
file = cfg.input_05;

opts = detectImportOptions(file);

% 第一行是单位说明，不是真正的数据
opts.DataLines = [3 Inf];

T = readtable(file,opts);

%% Convert variables if necessary
T.PH     = str2double(string(T.PH));
T.CTDPRS = str2double(string(T.CTDPRS));

T.time = datetime(T.time, ...
    'InputFormat',"yyyy-MM-dd'T'HH:mm:ss'Z'", ...
    'TimeZone','UTC');

%% Keep valid pH only
T = T(~isnan(T.PH),:);

% Surface: <= 20 dbar
T = T(T.CTDPRS <= 20,:);

%% Restrict to common historical period
T.Year = year(T.time);

T = T(T.Year >= 1992 & T.Year <= 2014,:);

fprintf('Valid HOT surface observations = %d\n',height(T));
fprintf('Period = %d-%d\n',min(T.Year),max(T.Year));
%% Annual means
[G,Year] = findgroups(T.Year);

pHannual = splitapply(@(x) mean(x,'omitnan'),T.PH,G);

valid = ~isnan(pHannual);

Year = Year(valid);
pHannual = pHannual(valid);

p = polyfit(Year,pHannual,1);

trend = p(1);

fprintf('HOT surface pH trend = %.6f pH/yr\n',trend);
fprintf('HOT surface pH trend = %.5f pH/decade\n',trend*10);
figure('Position',[100 100 850 550])

plot(Year,pHannual,'o-','LineWidth',1.5)
hold on

plot(Year,polyval(p,Year),'--','LineWidth',1.5)

xlabel('Year')
ylabel('Surface pH')
title('HOT / Station ALOHA Surface pH')

legend('Annual mean','Linear trend','Location','best')

grid on
box on

set(gca,...
    'FontName','Times New Roman',...
    'FontSize',12,...
    'LineWidth',1)
depthLimits = [10 20];
startYears  = [1992 1995 2000];
T_hot=T ;
for d = 1:length(depthLimits)

    for s = 1:length(startYears)

        Tmax = depthLimits(d);
        y0   = startYears(s);

        idx = ~isnan(T_hot.PH) & ...
              T_hot.CTDPRS <= Tmax;

        TT = T_hot(idx,:);

        TT.Year = year(TT.time);

        TT = TT(TT.Year >= y0 & TT.Year <= 2014,:);

        [G,Y] = findgroups(TT.Year);

        phY = splitapply(@(x) mean(x,'omitnan'),TT.PH,G);

        ok = ~isnan(phY);

        pp = polyfit(Y(ok),phY(ok),1);

        fprintf('%2d dbar, %d-2014 : %.6f pH/yr\n', ...
            Tmax,y0,pp(1));

    end
end
exportgraphics(gcf, ...
    fullfile(cfg.figure_dir, 'hot.png'), ...
    'Resolution',300);
Year_HOT=Year;
pH_HOT=pHannual;
save(fullfile(cfg.processed_dir, 'HOT_pH.mat'), ...
    'Year_HOT','pH_HOT');
