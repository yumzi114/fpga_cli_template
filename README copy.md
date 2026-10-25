# QMTECH Artix-7 CLI Blink

Vivado **2025.2** 기반 Tcl Project Mode 실험 프로젝트.

## 하드웨어

| 항목 | 구성 |
|---|---|
| FPGA 보드 | QMTECH Artix-7 XC7A100T DDR3 Core Board |
| FPGA Part | `xc7a100tfgg676-1` |
| JTAG | Digilent JTAG-HS3 Rev.A |
| JTAG USB ID | `0403:6014` (FT232H) |
| JTAG Serial | `210299BDCA52` |
| Configuration Flash | Micron MT25QL128, 128Mbit (16MB) |
| 외부 클럭 | 50MHz, U22, LVCMOS33 |
| LED0 / LED1 | T23 / R23, LVCMOS33 |
| 내부 클럭 | Clocking Wizard `clk_wiz_0`: 50MHz → 200MHz |

시작 시 외부 클럭 15사이클 동안 MMCM의 active-high reset을 유지하며,
`locked` 신호를 동기화한 뒤 LED 카운터를 구동한다.
LED 전환 간격은 현재 RTL의 카운터 설정에 따른다.
LED의 논리값과 실제 점등 방향은 보드 배선에 따라 달라질 수 있다.

## 빌드 및 프로그래밍

| 명령 | 기능 | 전원 재투입 후 |
|---|---|---|
| `make build` | IP 생성 → 합성 → 배치·배선 → 타이밍 검사 → Bitstream | — |
| `make program` | JTAG을 통한 FPGA SRAM 임시 프로그램 | 사라짐 |
| `make run` | 빌드 후 SRAM 임시 프로그램 | 사라짐 |
| `make flash` | **SPI Configuration Flash 영구 기록** | 유지됨 |
| `make timing` | `build/timing_summary.rpt` 보기 | — |
| `make utilization` | `build/utilization.rpt` 보기 | — |
| `make clean` | `build/` 출력물 삭제 | — |

> **주의:** 이 명령 표는 `make program`을 SRAM 업로드,
> `make flash`를 openFPGALoader의 `-f` 영구 기록으로 변경한
> **최신 Makefile 기준**이다. Makefile을 아직 수정하지 않았다면
> 기존 `make flash`는 Vivado를 통한 SRAM 업로드일 수 있다.
> SPI Flash 기록은 기존 부팅 이미지를 지우거나 덮어쓸 수 있다.

기본 Vivado 경로는 `/opt/Xilinx/2025.2/Vivado/bin/vivado`.
변경하려면 `make build VIVADO=/절대/경로/vivado`를 사용한다.

디자인, 생성 IP, 빌드 로그, 보고서와 Bitstream은 Git에서 제외되는
`build/`에 생성된다. GUI 확인용 프로젝트는 `build/project/blink.xpr`.
빌드는 매번 프로젝트를 재생성한다.

### FPGA SRAM 임시 업로드 (CLI)

```bash
openFPGALoader -c digilent_hs3 --fpga-part xc7a100tfgg676 build/blink.bit
```

### FPGA SPI Flash 영구 저장 (CLI)

먼저 FPGA 인식을 확인한다.

```bash
openFPGALoader -c digilent_hs3 --detect
```

장치가 `xc7a100`으로 검출되고 Bitstream을 확인한 후 실행한다.

```bash
openFPGALoader -c digilent_hs3 --fpga-part xc7a100tfgg676 -f build/blink.bit
```

기록 성공 시 보드의 5V 전원을 껐다 켜서 JTAG 재프로그램 없이 LED가
작동하는지 확인한다.

**현재 Arch Linux의 openFPGALoader 1.1.1에는
`qmtechArtix7_100T` 보드 정의가 없다.**
`-b qmtechArtix7_100T` 대신 검증한
`--fpga-part xc7a100tfgg676`를 사용한다.

## Arch Linux 개발 환경

| 패키지/도구 | 확인된 버전 | 용도 |
|---|---|---|
| AMD Vivado | 2025.2 | FPGA 합성·구현·Bitstream 생성 |
| `digilent.adept.runtime` | 2.30.1-1 | Digilent JTAG 런타임 |
| `digilent.adept.utilities` | 2.7.1-2 | `djtgcfg` |
| `libftdi` | 1.5-10 | FTDI USB 통신 |
| `libftdi-compat` | 0.20-10 | FTDI 호환 라이브러리 |
| `openfpgaloader` | 1.1.1-2 | SRAM/SPI Flash 프로그래밍 |
| `slang` | 2.3.3-4 | SystemVerilog 정적 분석 |

`glslang`은 GLSL 셰이더 컴파일러이며 FPGA용 `slang`과는 다르다.
`make`, `tclint`, Verible CLI 설치 여부는 아직 별도로 검증하지 않았다.

설치된 패키지 확인:

```bash
pacman -Q digilent.adept.runtime digilent.adept.utilities libftdi libftdi-compat openfpgaloader slang
vivado -version
make --version
slang --version
```

## VS Code Insiders 확장

`code-insiders --list-extensions --show-versions`로 확인한 설치 목록:

| 확장 ID | 버전 | 역할 |
|---|---|---|
| `caioplazas.slang-server-extended` | 0.7.0 | SystemVerilog LSP 및 진단 |
| `chipsalliance.verible` | 0.0.4296 | Verilog Lint 및 포맷 |
| `gladtbam.vivado-completion` | 0.2.0 | Vivado Tcl 자동완성 |
| `go2sh.tcl-language-support` | 0.1.2 | Tcl/XDC 구문 강조 |
| `nmoroze.tclint` | 0.1.5 | Tcl 구문 검사 |

```bash
code-insiders --list-extensions --show-versions
```

## 프로젝트 구성

```text
rtl/blink.v
constraints/blink.xdc
scripts/build.tcl
scripts/program.tcl
Makefile
README.md
```

## JTAG-HS3 on Arch Linux

Digilent Adept 라이브러리 경로는 `/usr/lib/digilent/adept/`.
동적 라이브러리 검색 경로가 등록되지 않았다면:

```bash
env LD_LIBRARY_PATH=/usr/lib/digilent/adept djtgcfg enum
```

기존에 생성한 udev 규칙:

```text
/etc/udev/rules.d/52-digilent-hs3.rules
/etc/udev/rules.d/52-digilent-usb.rules
```

FTDI 커널 드라이버가 HS3 인터페이스를 점유하면 다음 오류가 발생할 수 있다.

```text
unable to claim usb device: -5
Make sure the default FTDI driver is not in use
```

점유 여부 확인:

```bash
lsusb -t
```

다른 FTDI 시리얼 장치를 사용하지 않는 경우에만 일시적으로 드라이버를 내린다.

```bash
sudo modprobe -r ftdi_sio
```

## XDC 및 타이밍 검증

```tcl
set_property PACKAGE_PIN U22 [get_ports clk_50mhz]
set_property IOSTANDARD LVCMOS33 [get_ports clk_50mhz]
create_clock -name clk_50mhz -period 20.000 [get_ports clk_50mhz]

set_property PACKAGE_PIN T23 [get_ports {led[0]}]
set_property PACKAGE_PIN R23 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]
set_false_path -to [get_ports {led[*]}]
```

| 클럭 | 주파수 | 주기 |
|---|---|---|
| 외부 입력 | 50MHz | 20ns |
| MMCM 출력 | 200MHz | 5ns |

검증 항목: WNS ≥ 0ns, Setup/Hold/Pulse Width 위반 0개,
MMCM 인스턴스 1개. 다음은 **이전 Blink 버전**에서 확인한 수치이며,
현재 RTL 변경 후에는 다시 검사해야 한다.

```text
Setup WNS: +2.058ns
Hold WHS: +0.324ns
Failing Endpoints: 0
Timing Constraints: Met
```

LED 출력은 외부 동기 캡처가 없는 표시용 신호라 출력 경로를
false path로 지정했다. 내부 200MHz 경로의 타이밍은 계속 검사한다.
보드의 Configuration Bank 전압을 검증하기 전까지 CFGBVS 및
CONFIG_VOLTAGE 값은 추측해서 추가하지 않는다.