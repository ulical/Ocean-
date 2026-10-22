run(fullfile(fileparts(fileparts(mfilename('fullpath'))), 'config.m'));
file = cfg.input_19;

T = readtable(file);

T.Properties.VariableNames
head(T)
summary(T)
fprintf('总记录数 = %d\n', height(T));
fprintf('有效 PH 数量 = %d\n', sum(~isnan(T.PH)));

fprintf('最小 CTDPRS = %.2f dbar\n', min(T.CTDPRS,[],'omitnan'));
fprintf('最大 CTDPRS = %.2f dbar\n', max(T.CTDPRS,[],'omitnan'));
T.time = datetime(T.time, ...
    'InputFormat',"yyyy-MM-dd'T'HH:mm:ss'Z'", ...
    'TimeZone','UTC');

fprintf('最早年份 = %d\n', min(year(T.time)));
fprintf('最晚年份 = %d\n', max(year(T.time)));
T.Year = year(T.time);

for y = 1991:1993
    idx = T.Year == y & ~isnan(T.PH);
    fprintf('%d: N=%d, mean pH=%.4f\n', ...
        y, sum(idx), mean(T.PH(idx),'omitnan'));
end
T = readtable(cfg.input_19);

T.time = datetime(T.time, ...
    'InputFormat',"yyyy-MM-dd'T'HH:mm:ss'Z'", ...
    'TimeZone','UTC');

T.Year = year(T.time);

T = T(~isnan(T.PH),:);

T = T(T.CTDPRS <= 10,:);

% 只保留Total-scale时期 + CMIP6 historical共同结束年
T = T(T.Year >= 1992 & T.Year <= 2014,:);
[G,Year] = findgroups(T.Year);

pHannual = splitapply(@(x) mean(x,'omitnan'),T.PH,G);

valid = ~isnan(pHannual);

Year = Year(valid);
pHannual = pHannual(valid);
p = polyfit(Year,pHannual,1);

fprintf('HOT pH trend = %.6f pH/yr\n',p(1));
fprintf('HOT pH trend = %.5f pH/decade\n',p(1)*10);
