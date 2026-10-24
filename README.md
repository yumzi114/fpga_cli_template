# QMTECH Artix-7 CLI Blink

Vivado **2025.2**, FPGA **xc7a100tfgg676-1**, Tcl Project Mode 프로젝트.

| 신호 | 핀 | 규격 |
| --- | --- | --- |
| 50 MHz 입력 | U22 | LVCMOS33 |
| LED 0 | T23 | LVCMOS33 |
| LED 1 | R23 | LVCMOS33 |

Clocking Wizard `clk_wiz_0`가 50 MHz를 200 MHz로 변환합니다. 시작 시
15 입력 클럭 동안 active-high reset을 유지하고, locked를 동기화한 뒤
카운터를 구동합니다. 두 LED 출력은 0.5초마다 반전되어 각각 1 Hz로
점멸합니다. LED의 실제 점등 위상은 보드의 active-high/low 배선에 따릅니다.

```sh
make build        # IP 생성 → 합성 → 배치/배선 → 타이밍 검사 → bitstream
make flash        # Digilent JTAG-HS3로 FPGA SRAM 프로그래밍
make run          # build 성공 후 flash
make timing       # 마지막 빌드의 timing summary 출력
make utilization  # 마지막 빌드의 자원 사용량 출력
make clean        # build/ 삭제
```

기본 실행 파일은 `/opt/Xilinx/2025.2/Vivado/bin/vivado`입니다. 설치 위치가
다르면 `make build VIVADO=/절대/경로/vivado`로 지정합니다. Artix-7 디바이스
지원과 사용 가능한 Vivado 라이선스가 필요합니다.

프로젝트, 생성 IP, 실행 로그, 보고서와 `blink.bit`은 모두 Git에서 제외되는
`build/`에 저장합니다. `build/project/blink.xpr`로 GUI에서도 열 수 있습니다.
빌드는 매번 프로젝트를 재생성합니다. 명령 오류, 합성/구현 실패 또는
setup/hold/pulse-width 위반은 nonzero 종료 코드로 처리합니다.
LED는 외부 캡처 클럭이 없는 표시용 출력이므로 출력 경로를 false path로
지정합니다. 내부 200 MHz 경로는 타이밍 검사를 수행합니다.

JTAG-HS3를 연결하고 보드 전원을 켠 다음 `make flash`를 실행합니다.
Vivado Digilent 케이블 드라이버 및 USB 장치 접근 권한이 필요합니다.
Digilent 타깃이 여러 개이면 정확한 경로를 지정합니다.

```sh
make flash JTAG_TARGET='localhost:3121/xilinx_tcf/Digilent/장치시리얼'
```

`flash`는 FPGA의 휘발성 SRAM을 구성합니다. 전원 재투입 후 유지되는
SPI 구성 플래시 기록은 수행하지 않습니다. 하드웨어 프로그래밍 실패도
nonzero로 종료합니다.

구성 뱅크 전압 정보는 제공되지 않아 CFGBVS/CONFIG_VOLTAGE를 지정하지
않았습니다. Vivado의 CFGBVS-1 경고가 남으며, 보드 회로도로 전압을 확인한
뒤 해당 속성을 XDC에 추가할 수 있습니다.


## Development Environment

### Host

| Item | Version / Description |
|---|---|
| OS | Arch Linux x86_64 |
| FPGA Toolchain | AMD Vivado 2025.2 |
| FPGA Board | QMTECH Artix-7 XC7A100T DDR3 Core Board |
| FPGA Part | XC7A100T-FGG676-1 |
| JTAG Debugger | Digilent JTAG-HS3 Rev.A |
| JTAG USB ID | 0403:6014 (FT232H) |
| JTAG Serial | 210299BDCA52 |

### FPGA Board Configuration

| Resource | Specification |
|---|---|
| External Clock | 50MHz |
| Clock Input Pin | U22 |
| Internal Clock | 200MHz (MMCM) |
| LED0 | T23 |
| LED1 | R23 |
| I/O Standard | LVCMOS33 |
| Configuration Flash | Micron MT25QL128, 128Mbit |

## Arch Linux Development Tools

### Installed / Verified

| Package | Version | Purpose |
|---|---|---|
| Vivado | 2025.2 | FPGA synthesis, implementation, bitstream generation |
| digilent.adept.runtime | 2.30.1-1 | Digilent JTAG runtime |
| digilent.adept.utilities | 2.7.1-2 | Digilent JTAG utilities |
| libftdi | 1.5-10 | FTDI USB interface |
| libftdi-compat | 0.20-10 | FTDI compatibility library |
| openFPGALoader | Check installed version | FPGA programming and SPI Flash access |

### Recommended Development Tools

These tools were discussed for development. Verify installation
before marking them as installed.

| Tool | Purpose |
|---|---|
| GNU Make | Build automation |
| Slang | Verilog/SystemVerilog syntax and semantic analysis |
| Verible | SystemVerilog linting and formatting |
| tclint | Tcl script linting |
| Tcl Language Server | Tcl editor diagnostics and completion |

Check installed versions:

```bash
vivado -version
pacman -Q digilent.adept.runtime digilent.adept.utilities
pacman -Q libftdi libftdi-compat
pacman -Q openfpgaloader
make --version
slang --version
verible-verilog-lint --version
tclint --version
```

## VS Code Extensions

The following extensions are recommended for the FPGA development workflow.
Installation status should be verified separately.

| Extension | Extension ID | Purpose |
|---|---|---|
| Slang Server | Hudson-River-Trading.vscode-slang | SystemVerilog LSP, diagnostics |
| Verible | CHIPSAlliance.verible | SystemVerilog lint and formatting |
| TCL Language Support | go2sh.tcl-language-support | Tcl/XDC syntax highlighting |
| tclint Language Server | nmoroze.tclint | Tcl linting and diagnostics |
| Vivado Completion | Gladtbam.vivado-completion | Vivado Tcl command completion |

List installed VS Code extensions:

```bash
code --list-extensions --show-versions
```

## Build Workflow

Source files:

```text
rtl/blink.v
constraints/blink.xdc
scripts/build.tcl
scripts/program.tcl
Makefile
```

Build FPGA bitstream:

```bash
make build
```

Program FPGA SRAM (volatile):

```bash
make flash
```

Build and program:

```bash
make run
```

View timing report:

```bash
make timing
```

View resource utilization:

```bash
make utilization
```

> Note: The meaning of `make flash` depends on the current Makefile.
> In the initial project, it programs FPGA SRAM rather than SPI Flash.

## JTAG-HS3 on Arch Linux

### Digilent Adept

The Digilent libraries are installed under:

```text
/usr/lib/digilent/adept/
```

The library path may not be registered with the system linker.

Enumerate JTAG devices:

```bash
env LD_LIBRARY_PATH=/usr/lib/digilent/adept djtgcfg enum
```

Expected device:

```text
Device: JtagHs3
Product Name: Digilent JTAG-HS3
Serial Number: 210299BDCA52
```

### udev Rules

The following rules were previously configured:

```text
/etc/udev/rules.d/52-digilent-hs3.rules
/etc/udev/rules.d/52-digilent-usb.rules
```

### FTDI Driver Conflict

The Linux `ftdi_sio` driver can claim the HS3 USB interface,
preventing openFPGALoader from accessing it.

Typical error:

```text
unable to claim usb device: -5
Make sure the default FTDI driver is not in use
```

Inspect USB drivers:

```bash
lsusb -t
```

If no other FTDI serial devices are in use, temporarily unload:

```bash
sudo modprobe -r ftdi_sio
```

Detect the FPGA:

```bash
openFPGALoader -c digilent_hs3 --detect
```

## FPGA Programming

### Volatile Programming (SRAM)

```bash
openFPGALoader \
    -b qmtechArtix7_100T \
    -c digilent_hs3 \
    build/blink.bit
```

The FPGA loses its configuration when power is removed.

### Persistent Programming (SPI Flash)

**Warning: This overwrites existing configuration data in SPI Flash.**

Verify the connected device and preserve any important existing
Flash contents before programming.

```bash
openFPGALoader \
    -b qmtechArtix7_100T \
    -c digilent_hs3 \
    -f build/blink.bit
```

After successful programming, power-cycle the board and verify
that the FPGA configures automatically.

## Timing Verification

The external clock is constrained in XDC:

```tcl
create_clock -name clk_50mhz -period 20.000 [get_ports clk_50mhz]
```

The Clocking Wizard generates an internal 200MHz clock.

Expected timing requirements:

| Clock | Frequency | Period |
|---|---|---|
| External | 50MHz | 20ns |
| Internal | 200MHz | 5ns |

Check:

- WNS >= 0ns
- No failing setup endpoints
- No failing hold endpoints
- MMCM present in utilization report

Previously verified timing result:

```text
Setup WNS: +2.058ns
Hold WHS: +0.324ns
Failing Endpoints: 0
Timing Constraints: Met
```

This result applies to the earlier tested Blink design.
Revalidate timing after RTL or clock changes.


# FPGA 관련 Arch 패키지
pacman -Q digilent.adept.runtime \
  digilent.adept.utilities \
  libftdi libftdi-compat \
  openfpgaloader slang

# VS Code Insiders 확장
code-insiders --list-extensions --show-versions