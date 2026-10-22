# 海洋酸化：CMIP6 pH 与碳酸盐缓冲能力

研究代码整理版，分析 CESM2、MPI-ESM1-2-LR、IPSL-CM6A-LR，以及 HOT、BATS 和 GLODAP 观测。所有分析脚本均基于现有原文件整理；没有虚构作者经历或结果。

## 使用

1. 在 MATLAB 中打开本目录，编辑 `config.m` 的数据目录和 CO2SYS、M_Map 路径。
2. 按 `data/README.md` 准备文件。原始大数据不在仓库中。
3. 运行 `run_project` 执行主流程，或单独运行 scripts 中的脚本。09 需要逐年计算，耗时较长。
4. 图件写入 `figures/`，中间 MAT 写入 `data/processed/`。不要直接运行全部 diagnostics。

依赖：MATLAB、Statistics and Machine Learning Toolbox（tcdf、prctile）、CO2SYS、M_Map。检测到本机安装 R2025b；实际验证范围见 `docs/VALIDATION.md`，这不等同于完整计算已验证。`environment.yml` 仅供可选 Python 数据检查，不安装 MATLAB 或替代 MATLAB 分析；未锁定完整依赖版本。

## 脚本顺序与图件

| 步骤 | 内容 | 脚本 |
|---|---|---|
| 01 | 全球 pH 与三模式比较 | 01a–01d |
| 02 | HOT、BATS 表层 pH | 02a–02c |
| 03–05 | CESM2、MPI、IPSL 与 GLODAP 剖面对比 | 03、04、05 |
| 06 | CESM2 月度温盐转年度表层场 | 06 |
| 07 | 站点与 2014 全球 pH 自洽性 | 07a、07b |
| 08 | 1850、2014 Revelle 及差值 | 08 |
| 09 | Revelle 趋势与显著性图 | 09 |

实际导出文件逐项列在 [docs/FIGURES.md](docs/FIGURES.md)。报告原文未提供，图号没有强行命名为 Fig1–Fig6。

## 方法及待验证项

- DIC/TA 按固定密度 1025 kg/m³ 将 mol/m³ 转成 µmol/kg；CESM2 剖面按原代码把 lev 的 cm 转为 m，仍须核对文件元数据。
- CO2SYS 沿用 Total pH scale、K1/K2=10、KSO4=1。表层模式计算压力为 0 dbar、营养盐为零；BATS 用深度近似压力，缺测营养盐置零。输出列 3=pH、14=Revelle 的对应关系须与实际 CO2SYS 版本核实。
- CESM2 温盐按 noleap 每月天数加权；MPI/IPSL 全球 pH 和剖面沿用月度等权平均。先年平均再计算碳酸盐体系存在非线性误差。
- GLODAP 观测筛选为 1992–2014；MPI/IPSL 模式剖面是 1990–2014，时段不完全一致。站点最近格点未额外筛选海陆。
- HOT 主脚本 ≤20 dbar，诊断版 ≤10 dbar；BATS ≤10 m。HOT pH 标度、BATS 单位与原始质控旗标须人工确认。
- Revelle 趋势图黑点为普通 OLS 斜率双侧 t 检验 p<0.05，至少 100 个有效年份；未校正时间自相关或多重检验。另一个趋势数组采用至少 30 年阈值，原逻辑保留。
- 09 缺少 areacello 时沿用 cos(latitude) 近似；曲线网格应优先使用真实面积。色标沿用原稿，可能裁切极值。

## 来源与上传前核对

[docs/provenance.json](docs/provenance.json) 记录每个原文件路径和 SHA-256；[docs/CHANGES.md](docs/CHANGES.md) 记录实质修正。用户列出的 15 个 .m 均已找到，额外找到 mpidata.m、ipsl.m 并纳入；hotbats.asv 是备份，未作为独立分析。没有缺少原始 .m 而推测重写的部分。新建的是配置、运行入口及文档。

仍需补充：最终报告图号、数据 DOI/版本/质控说明、CO2SYS/M_Map 版本、完整运行结果及必要的作者/引用信息。原脚本不代表数据和统计假设已经通过验证。

这是本地 Git 仓库，尚未上传，也没有设置远程地址。原始 G 盘文件未改动。
