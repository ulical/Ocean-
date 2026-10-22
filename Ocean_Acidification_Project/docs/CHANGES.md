# 整理记录

- mpidata.m：补存自身生成的 MPI 年平均序列，供三模式比较使用。
- ipsl.m：删除末尾把 IPSL 结果误存为 MPI_surface_pH.mat 的两行。
- hotbats.m：删除随即被 clear 清除的初始无关读表。
- cesmtsdataprocess.m：valcidS 更正为 validS。
- 注释精简；本地路径移到 config.m；图件统一写入 figures/，中间 MAT 写入 data/processed/。
- 全部科学分析主体来自现有 .m 文件，没有从对话推测补写科学分析。
- 保留固定密度、时间索引、深度筛选、CO2SYS 参数和原统计方法。
