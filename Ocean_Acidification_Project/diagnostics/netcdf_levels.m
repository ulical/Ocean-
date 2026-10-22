run(fullfile(fileparts(fileparts(mfilename('fullpath'))), 'config.m'));
file = cfg.input_01;

ncdisp(file)
file = cfg.input_08;

lev = ncread(file,'lev');
lev_bnds = ncread(file,'lev_bnds');

disp('lev 前10层：')
disp(lev(1:10))

disp('lev_bnds 前10层：')
disp(lev_bnds(:,1:10))
