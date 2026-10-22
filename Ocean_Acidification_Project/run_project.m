%% Run analyses in order
project_root = fileparts(mfilename('fullpath'));
addpath(project_root);
run(fullfile(fileparts(mfilename('fullpath')), 'scripts', '01a_CESM2_global_pH.m'));
run(fullfile(fileparts(mfilename('fullpath')), 'scripts', '01b_MPI_global_pH.m'));
run(fullfile(fileparts(mfilename('fullpath')), 'scripts', '01c_IPSL_global_pH.m'));
run(fullfile(fileparts(mfilename('fullpath')), 'scripts', '01d_three_model_pH.m'));
run(fullfile(fileparts(mfilename('fullpath')), 'scripts', '02a_HOT_pH.m'));
run(fullfile(fileparts(mfilename('fullpath')), 'scripts', '02b_BATS_pH.m'));
run(fullfile(fileparts(mfilename('fullpath')), 'scripts', '02c_HOT_BATS_plot.m'));
run(fullfile(fileparts(mfilename('fullpath')), 'scripts', '03_CESM2_GLODAP_profiles.m'));
run(fullfile(fileparts(mfilename('fullpath')), 'scripts', '04_MPI_GLODAP_profiles.m'));
run(fullfile(fileparts(mfilename('fullpath')), 'scripts', '05_IPSL_GLODAP_profiles.m'));
run(fullfile(fileparts(mfilename('fullpath')), 'scripts', '06_CESM2_surface_TS.m'));
run(fullfile(fileparts(mfilename('fullpath')), 'scripts', '07a_station_pH_consistency.m'));
run(fullfile(fileparts(mfilename('fullpath')), 'scripts', '07b_global_pH_consistency_2014.m'));
run(fullfile(fileparts(mfilename('fullpath')), 'scripts', '08_CESM2_Revelle_endpoints.m'));
run(fullfile(fileparts(mfilename('fullpath')), 'scripts', '09_CESM2_Revelle_trend.m'));
