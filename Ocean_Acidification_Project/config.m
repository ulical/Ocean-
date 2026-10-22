%% Local paths
project_root = fileparts(mfilename('fullpath'));
cfg.data_root = 'G:/CMIP6datafordissic';
cfg.ph_root = 'G:/CMIP6dataforph';
cfg.co2sys_path = ''; % Folder containing CO2SYS.m; leave empty if already on path.
cfg.m_map_path = ''; % Folder containing m_proj.m.
cfg.processed_dir = fullfile(project_root, 'data', 'processed');
cfg.figure_dir = fullfile(project_root, 'figures');
if ~isfolder(cfg.processed_dir), mkdir(cfg.processed_dir); end
if ~isfolder(cfg.figure_dir), mkdir(cfg.figure_dir); end
if ~isempty(cfg.co2sys_path), addpath(genpath(cfg.co2sys_path)); end
if ~isempty(cfg.m_map_path), addpath(genpath(cfg.m_map_path)); end
cfg.input_01 = fullfile(cfg.data_root, 'ph_Oyr_CESM2_historical_r1i1p1f1_gn_1850-2014.nc');
cfg.input_02 = fullfile(cfg.data_root, 'areacello_Ofx_CESM2_historical_r1i1p1f1_gn.nc');
cfg.input_03 = fullfile(cfg.ph_root, 'MPI-ESM1-2-LR');
cfg.input_04 = fullfile(cfg.ph_root, 'IPSL-CM6A-LR');
cfg.input_05 = fullfile(cfg.data_root, 'bcodmo_dataset_3773_a2dd_348e_2b61.csv');
cfg.input_06 = fullfile(cfg.data_root, '3782_v10_bats_bottle.csv');
cfg.input_07 = fullfile(cfg.data_root, 'GLODAPv3_Merged_Master_File.mat');
cfg.input_08 = fullfile(cfg.data_root, 'dissic_Oyr_CESM2_historical_r1i1p1f1_gn_1850-2014.nc');
cfg.input_09 = fullfile(cfg.data_root, 'talk_Oyr_CESM2_historical_r1i1p1f1_gn_1850-2014.nc');
cfg.input_10 = fullfile(cfg.ph_root, 'MPI-ESM1-2-LR/dissic_Omon_MPI-ESM1-2-LR_historical_r1i1p1f1_gn_199001-200912.nc');
cfg.input_11 = fullfile(cfg.ph_root, 'MPI-ESM1-2-LR/dissic_Omon_MPI-ESM1-2-LR_historical_r1i1p1f1_gn_201001-201412.nc');
cfg.input_12 = fullfile(cfg.ph_root, 'MPI-ESM1-2-LR/talk_Omon_MPI-ESM1-2-LR_historical_r1i1p1f1_gn_199001-200912.nc');
cfg.input_13 = fullfile(cfg.ph_root, 'MPI-ESM1-2-LR/talk_Omon_MPI-ESM1-2-LR_historical_r1i1p1f1_gn_201001-201412.nc');
cfg.input_14 = fullfile(cfg.ph_root, 'IPSL-CM6A-LR/dissic_Omon_IPSL-CM6A-LR_historical_r1i1p1f1_gn_195001-201412.nc');
cfg.input_15 = fullfile(cfg.ph_root, 'IPSL-CM6A-LR/talk_Omon_IPSL-CM6A-LR_historical_r1i1p1f1_gn_195001-201412.nc');
cfg.input_16 = fullfile(cfg.data_root, 'thetao_Omon_CESM2_historical_r1i1p1f1_gn_185001-201412.nc');
cfg.input_17 = fullfile(cfg.data_root, 'so_Omon_CESM2_historical_r1i1p1f1_gn_185001-201412.nc');
cfg.input_18 = fullfile(cfg.data_root, '*areacello*CESM2*.nc');
cfg.input_19 = fullfile(cfg.data_root, 'bcodmo_dataset_3773_5afa_2961_8971.csv');
