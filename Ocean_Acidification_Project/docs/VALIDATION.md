# 验证记录

日期：2026-10-22（新加坡时间）。

- 17 个原始 .m 的来源与 SHA-256 已记录；用户指定的 15 个 .m 均找到，另补入 MPI/IPSL 全球 pH 原脚本。
- 原注释行 458，整理后 80（包括章节标题）。保留方法、单位和转换说明。
- 静态检查输入路径：19 个配置项，缺失 0 个；通配符仅检查至少存在匹配文件，未证明时间连续、网格一致或数据正确。
- MATLAB R2025b 启动失败：`System Error: File system inconsistency`，退出码 1。MATLAB 未执行 checkcode，也未执行分析；没有声称语法检查通过或数值等价。
- 未安装或运行辅助 Conda 环境，未验证 CO2SYS/M_Map 的版本与可用性。
- 未执行完整数据计算，未将原始 MAT 文件复制到 processed/。尤其旧 MPI_surface_pH.mat 可能受 IPSL 原脚本误存影响，应重新生成。
- 已核对导出文件映射并保留原输出名。既有图件仅复制到 figures/existing/，没有被标记成重算结果。

缺失路径：

未发现配置中明确列出的文件/目录缺失。

既有图件来源：

- `G:\CMIP6datafordissic\CESM2_Revelle_trend_1850_2014 with significance.png`
- `G:\CMIP6datafordissic\CESM2_Revelle_trend_1850_2014.png`
- `G:\CMIP6datafordissic\HOT_BATS_pH_anomaly.pdf`
- `G:\CMIP6datafordissic\HOT_BATS_pH_trend.pdf`
- `G:\CMIP6dataforph\IPSL-CM6A-LR Global Area-Weighted Surface pH.png`
- `G:\CMIP6dataforph\MPI_surface_pH_1850_2014.png`

上传前仍需在可正常启动的 MATLAB 中完成逐步运行；核对最终报告图号、观测质控、CO2SYS 输出列、数据 DOI/版本。

Git 暂存差异空白检查通过；分析脚本中的旧盘符路径均已移至配置。此项不是 MATLAB 语法或运行检查。
