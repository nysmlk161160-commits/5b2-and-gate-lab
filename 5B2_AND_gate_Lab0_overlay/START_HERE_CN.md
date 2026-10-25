# 5B2 Lab 0: Tiny Tapeout SKY130 AND gate 练习

此压缩包是官方 Tiny Tapeout SKY130 Verilog 模板的**文件替换包**，不是完整官方工程。
官方模板：https://github.com/TinyTapeout/ttsky-verilog-template

## 使用方法

1. 打开官方仓库，选择 **Use this template → Create a new repository**。
2. 选择 Public，创建自己的仓库（例如 `5b2-and-gate-lab`）。
3. 保留模板现有 `.github/workflows/`、`test/Makefile`、`test/requirements.txt` 等全部文件。
4. 将本 ZIP 中 `src/project.v`、`info.yaml`、`test/tb.v`、`test/test.py`、`docs/info.md` 上传至你的仓库中的**对应同名路径**，替换原文件。
5. 不要将替换文件放错目录。`src/project.v` 顶层模块 `tt_um_and_demo` 必须与 `info.yaml` 的 `top_module` 和 `test/tb.v` 实例名一致。
6. 在 `info.yaml` 中将 author 改成你的姓名；这是教学版模块名，正式递交时要换成包含个人 GitHub 用户名的唯一 `tt_um_...` 名称，同时同步改 3 处。
7. 在 Settings → Pages → Build and deployment → Source 选择 **GitHub Actions**。
8. 每次 Commit 后，到 Actions 查看 `test`（RTL）、`gds`（LibreLane ASIC 流程和 precheck、gl_test）及 `docs`。
9. 在成功的 test run 的 Artifacts 下载 `test-results`，解压后用 GTKWave 打开 `tb.fst`，查看 `ui_in[0]`、`ui_in[1]` 和 `uo_out[0]`。
10. 在成功的 gds run 的 Summary 查看 cell usage、metrics、Precheck、2D/3D viewer，并在 Artifacts 下载 GDS 相关资料；artifact 名称和目录可能随版本改变。
11. 填写 `lab0_results_template.csv`，明确注明哪些数据不可用（如纯组合电路的 Fmax、未可靠估计的功耗）。

## 原理

AND Gate：A=ui_in[0]，B=ui_in[1]，Y=uo_out[0]；其他输出位全部为 0。此电路不使用 clk/rst_n，`clock_hz` 设置为 0。

## 工具对应

- RTL 仿真：Icarus Verilog + Cocotb；文件为 `src/project.v`、`test/tb.v`、`test/test.py`
- 综合：LibreLane 中的综合流程，将布尔逻辑映射到 SkyWater SKY130 标准单元
- 物理实现：Floorplan、Placement、Routing、GDSII
- 验证：同一功能测试在 RTL 和 GL Netlist 上运行；另外检查 Precheck、DRC/LVS（按日志具体结果）
- 版图：GDSII，可通过官方 Viewer 或 KLayout 查看

## 注意

没有实际 GitHub Actions 运行之前，不能声称 RTL、GL、DRC、LVS 或 GDS 已通过。这里提供的是经过配置审阅的示例文件，未在本地执行 Icarus/LibreLane 流程。
