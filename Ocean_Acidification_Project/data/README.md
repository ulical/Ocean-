# 数据要求

原始数据不随仓库分发。config.m 列出了每个实际文件名；修改 data_root、ph_root 后检查 input 字段。

- CESM2 historical r1i1p1f1 gn：1850–2014 年度 ph、dissic、talk；185001–201412 月度 thetao、so；areacello。勿混用 gr 网格。
- MPI-ESM1-2-LR historical r1i1p1f1 gn：1850–2014 全部月度 ph 分段和 areacello；199001–200912、201001–201412 的 dissic/talk。
- IPSL-CM6A-LR historical r1i1p1f1 gn：1850–2014 全部月度 ph 分段（原脚本从首文件读取 area）；195001–201412 的 dissic/talk。
- GLODAPv3_Merged_Master_File.mat：latitude、longitude、depth、year、tco2、talk；DIC/TA 应为 µmol/kg。
- HOT：bcodmo_dataset_3773_a2dd_348e_2b61.csv（主流程，跳过单位行，≤20 dbar）；诊断版使用 bcodmo_dataset_3773_5afa_2961_8971.csv（≤10 dbar）。
- BATS：3782_v10_bats_bottle.csv，Depth、Temperature、Salinity、CTD_Salinity、CO2、Alkalinity、PO4、Silicate、decimal_year；主流程 ≤10 m，1992–2014。

数据入口（未代替具体下载记录）：[ESGF](https://esgf.llnl.gov/)、[BCO-DMO](https://www.bco-dmo.org/)、[GLODAP](https://glodap.info/)。上传前补充实际数据 DOI、版本、下载日期、质控旗标处理及文件校验值；这些信息不能仅由本地文件名推断。

processed/ 由脚本生成，不入 Git。按 01a–01c 重新生成三模式序列后再运行 01d，避免使用来源未核实的旧 MAT 文件。
