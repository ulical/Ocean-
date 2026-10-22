run(fullfile(fileparts(fileparts(mfilename('fullpath'))), 'config.m'));
file = cfg.input_06;

T = readtable(file);

T.Properties.VariableNames
summary(T(:,{'Depth','Temperature','Salinity','CTD_Salinity', ...
            'CO2','Alkalinity','PO4','Silicate','decimal_year'}))
fprintf('CO2/DIC range = %.1f to %.1f\n', ...
    min(T.CO2,[],'omitnan'), max(T.CO2,[],'omitnan'));

fprintf('TA range = %.1f to %.1f\n', ...
    min(T.Alkalinity,[],'omitnan'), max(T.Alkalinity,[],'omitnan'));
T = T(T.Depth <= 10,:);
T = T(T.decimal_year >= 1992 & T.decimal_year <= 2014,:);
S = T.Salinity;

idx = isnan(S);
S(idx) = T.CTD_Salinity(idx);

T.S_use = S;

valid = ~isnan(T.CO2) & ...
        ~isnan(T.Alkalinity) & ...
        ~isnan(T.Temperature) & ...
        ~isnan(T.S_use);

T = T(valid,:);
fprintf('Valid surface carbonate observations = %d\n',height(T));
fprintf('Period = %.1f–%.1f\n', ...
    min(T.decimal_year),max(T.decimal_year));
TA  = T.Alkalinity;
DIC = T.CO2;

SAL = T.S_use;
TEMP = T.Temperature;

% 表层压力，先近似用Depth(m)≈Pressure(dbar)
PRES = T.Depth;

% nutrients
PO4 = T.PO4;
SI  = T.Silicate;

% 如果营养盐缺测，第一版先设为0
PO4(isnan(PO4)) = 0;
SI(isnan(SI))   = 0;

[RESULT,HEADERS,NICEHEADERS] = CO2SYS( ...
    TA,DIC,1,2, ...
    SAL,TEMP,TEMP, ...
    PRES,PRES, ...
    SI,PO4, ...
    1,10,1);
disp(NICEHEADERS(1:20))
T.pH_calc = RESULT(:,3);

fprintf('Calculated pH range = %.3f to %.3f\n', ...
    min(T.pH_calc),max(T.pH_calc));

fprintf('Mean calculated pH = %.3f\n', ...
    mean(T.pH_calc,'omitnan'));
T.Year = floor(T.decimal_year);

[G,Year] = findgroups(T.Year);

pHannual = splitapply(@(x) mean(x,'omitnan'),T.pH_calc,G);

ok = ~isnan(pHannual);

Year = Year(ok);
pHannual = pHannual(ok);

p = polyfit(Year,pHannual,1);

fprintf('BATS calculated pH trend = %.6f pH/yr\n',p(1));
fprintf('BATS calculated pH trend = %.5f pH/decade\n',p(1)*10);
Year_BATS=Year;
pH_BATS=pHannual;
save(fullfile(cfg.processed_dir, 'BATS_pH.mat'), ...
    'Year_BATS','pH_BATS');
