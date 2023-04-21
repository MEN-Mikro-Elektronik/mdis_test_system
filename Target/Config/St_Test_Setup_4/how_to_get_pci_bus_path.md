# **HOW TO GET THE PCI BUS PATH**

## **STEP #1: Get PCI geographical path of the Board you want to transform to PCI_BUS_PATH.**


First of all, you have to check the system.dsc generated with the system_scan script as there you can get
the PCI BUS & PCI DEVICE NUMBER of the device you want to get its PCI_BUS_PATH.

In our case, as we are working with the F27P CPU Board and we are trying to compute the PCI_BUS_PATH
of a Carrier Board (F205). We have:


```
d203_1 {

    # ------------------------------------------------------------------------
    #        general parameters (don't modify)
    # ------------------------------------------------------------------------
    DESC_TYPE = U_INT32 0x2
    HW_TYPE = STRING D203
    _WIZ_MODEL = STRING F205
    _WIZ_BUSIF = STRING cpu,1

    # ------------------------------------------------------------------------
    #        PCI configuration
    # ------------------------------------------------------------------------
    PCI_BUS_NUMBER = U_INT32 0x6
    PCI_DEVICE_ID = U_INT32 0xf
    
	# ------------------------------------------------------------------------
    #        debug levels (optional)
    #        these keys have only effect on debug drivers
    # ------------------------------------------------------------------------
    DEBUG_LEVEL = U_INT32 0xc0008000
    DEBUG_LEVEL_BK = U_INT32 0xc0008000
    DEBUG_LEVEL_OSS = U_INT32 0xc0008000
    DEBUG_LEVEL_DESC = U_INT32 0xc0008000
}
```

From here, we can get the PCI information of where the F205 is currently connected. In our case:

```
PCI_BUS_NUMBER = U_INT32 0x6
PCI_DEVICE_ID = U_INT32 0xf
```

So, the F205 Carrier board is connected in PCI geographical address: 06:0F.0

## **STEP #2 Get information about the PCI Peripehals on the system.**

Just run the bash command: lspci -vvv

In our case, we got:

```
user@machine:~$ lspci -vvv
00:00.0 Host bridge: Advanced Micro Devices, Inc. [AMD] Device 15d0
	Subsystem: Advanced Micro Devices, Inc. [AMD] Device 15d0
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-

00:01.0 Host bridge: Advanced Micro Devices, Inc. [AMD] Family 17h (Models 00h-0fh) PCIe Dummy Host Bridge
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-

00:01.3 PCI bridge: Advanced Micro Devices, Inc. [AMD] Device 15d3 (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin ? routed to IRQ 25
	Bus: primary=00, secondary=01, subordinate=06, sec-latency=0
	I/O behind bridge: 00008000-0000bfff
	Memory behind bridge: f3800000-f52fffff
	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: <access denied>
	Kernel driver in use: pcieport

00:01.4 PCI bridge: Advanced Micro Devices, Inc. [AMD] Device 15d3 (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin ? routed to IRQ 26
	Bus: primary=00, secondary=07, subordinate=0b, sec-latency=0
	I/O behind bridge: 0000c000-0000efff
	Memory behind bridge: f0800000-f30fffff
	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: <access denied>
	Kernel driver in use: pcieport

00:01.5 PCI bridge: Advanced Micro Devices, Inc. [AMD] Device 15d3 (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin ? routed to IRQ 27
	Bus: primary=00, secondary=0c, subordinate=0c, sec-latency=0
	I/O behind bridge: 0000f000-00000fff
	Memory behind bridge: e8000000-f00fffff
	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: <access denied>
	Kernel driver in use: pcieport

00:01.6 PCI bridge: Advanced Micro Devices, Inc. [AMD] Device 15d3 (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin ? routed to IRQ 28
	Bus: primary=00, secondary=0d, subordinate=0d, sec-latency=0
	I/O behind bridge: 0000f000-00000fff
	Memory behind bridge: d8000000-e00fffff
	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: <access denied>
	Kernel driver in use: pcieport

00:01.7 PCI bridge: Advanced Micro Devices, Inc. [AMD] Device 15d3 (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin ? routed to IRQ 29
	Bus: primary=00, secondary=0e, subordinate=0e, sec-latency=0
	I/O behind bridge: 0000f000-00000fff
	Memory behind bridge: f5a00000-f5afffff
	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <S** **

00:08.0 Host bridge: Advanced Micro Devices, Inc. [AMD] Family 17h (Models 00h-0fh) PCIe Dummy Host Bridge
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-

00:08.1 PCI bridge: Advanced Micro Devices, Inc. [AMD] Device 15db (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 30
	Bus: primary=00, secondary=0f, subordinate=0f, sec-latency=0
	I/O behind bridge: 0000f000-0000ffff
	Memory behind bridge: f5400000-f58fffff
	Prefetchable memory behind bridge: 00000000c0000000-00000000d01fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: <access denied>
	Kernel driver in use: pcieport

00:08.2 PCI bridge: Advanced Micro Devices, Inc. [AMD] Device 15dc (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoB000000000fffff** **
	Kernel driver in use: pcieport

00:14.0 SMBus: Advanced Micro Devices, Inc. [AMD] FCH SMBus Controller (rev 61)
	Subsystem: Advanced Micro Devices, Inc. [AMD] FCH SMBus Controller
	Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap- 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Kernel driver in use: piix4_smbus
	Kernel modules: i2c_piix4, sp5100_tco

00:14.3 ISA bridge: Advanced Micro Devices, Inc. [AMD] FCH LPC Bridge (rev 51)
	Subsystem: Advanced Micro Devices, Inc. [AMD] FCH LPC Bridge
	Control: I/O+ Mem+ BusMaster+ SpecCycle+ MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0

00:18.0 Host bridge: Advanced Micro Devices, Inc. [AMD] Device 15e8
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-

00:18.1 Host bridge: Advanced Micro Devices, Inc. [AMD] Device 15e9
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-

00:18.2 Host bridge: Advanced Micro Devices, Inc. [AMD] Device 15ea
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-

00:18.3 Host bridge: Advanced Micro Devices, Inc. [AMD] Device 15eb
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Kernel driver in use: k10temp
	Kernel modules: k10temp

00:18.4 Host bridge: Advanced Micro Devices, Inc. [AMD] Device 15ec
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-

00:18.5 Host bridge: Advanced Micro Devices, Inc. [AMD] Device 15ed
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-

00:18.6 Host bridge: Advanced Micro Devices, Inc. [AMD] Device 15ee
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-

00:18.7 Host bridge: Advanced Micro Devices, Inc. [AMD] Device 15ef
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-

01:00.0 PCI bridge: Pericom Semiconductor Device 2404 (rev 05) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=01, secondary=02, subordinate=06, sec-latency=0BAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: <access denied>

02:01.0 PCI bridge: Pericom Semiconductor Device 2404 (rev 05) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin ? routed to IRQ 32
	Bus: primary=02, secondary=03, subordinate=03, sec-latency=0
	I/O behind bridge: 0000b000-0000bfff
	Memory behind bridge: f4800000-f50fffff
	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: <access denied>
	Kernel driver in use: pcieport

02:02.0 PCI bridge: Pericom Semiconductor Device 2404 (rev 05) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin ? routed to IRQ 33
	Bus: primary=02, secondary=04, subordinate=04, sec-latency=0
	I/O behind bridge: 0000a000-0000afff
	Memory behind bridge: f3800000-f40fffff
	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: <access denied>
	Kernel driver in use: pcieport

02:03.0 PCI bridge: Pericom Semiconductor Device 2404 (rev 05) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin ? routed to IRQ 34
	Bus: primary=02, secondary=05, subordinate=06, sec-latency=0
	I/O behind bridge: 00008000-00009fff
	Memory behind bridge: f5200000-f52fffff
	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: <access denied>
	Kernel driver in use: pcieport

03:00.0 Ethernet controller: Intel Corporation I211 Gigabit Network Connection (rev 03)
	Subsystem: Intel Corporation I211 Gigabit Network Connection
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 55
	Region 0: Memory at f4800000 (32-bit, non-prefetchable) [size=8M]
	Region 2: I/O ports at b000 [disabled] [size=32]
	Region 3: Memory at f5000000 (32-bit, non-prefetchable) [size=16K]
	Capabilities: <access denied>
	Kernel driver in use: igb
	Kernel modules: igb

04:00.0 Ethernet controller: Intel Corporation I211 Gigabit Network Connection (rev 03)
	Subsystem: Intel Corporation I211 Gigabit Network Connection
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 65
	Region 0: Memory at f3800000 (32-bit, non-prefetchable) [size=8M]
	Region 2: I/O ports at a000 [disabled] [size=32]
	Region 3: Memory at f4000000 (32-bit, non-prefetchable) [size=16K]
	Capabilities: <access denied>
	Kernel driver in use: igb
	Kernel modules: igb

05:00.0 PCI bridge: Texas Instruments XIO2001 PCI Express-to-PCI Bridge (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=05, secondary=06, subordinate=06, sec-latency=32
	I/O behind bridge: 00008000-00009fff
	Memory behind bridge: f5200000-f52fffff
	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
	Secondary status: 66MHz+ FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
	BridgeCtl: Parity- SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: <access denied>

06:0d.0 Bridge: Altera Corporation Device 4d45 (rev 01)
	Subsystem: Device 004b:5a14
	Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Interrupt: pin A routed to IRQ 108
	Region 0: I/O ports at 8000 [size=4K]
	Region 1: I/O ports at 9000 [size=256]
	Region 2: Memory at f5220000 (32-bit, non-prefetchable) [size=64K]
	Region 3: Memory at f5210000 (32-bit, non-prefetchable) [size=64K]
	Region 4: Memory at f5200000 (32-bit, non-prefetchable) [size=64K]
	Kernel modules: mcb_pci, altera_cvp

06:0f.0 Bridge: Altera Corporation Device d203 (rev e3)
	Subsystem: Device ff00:ff00
	Control: I/O- Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap- 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Interrupt: pin A routed to IRQ 65
	Region 0: Memory at f5230000 (32-bit, non-prefetchable) [size=4K]
	Kernel modules: altera_cvp

07:00.0 PCI bridge: Pericom Semiconductor Device 2404 (rev 05) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Bus: primary=07, secondary=08, subordinate=0b, sec-latency=0
	I/O behind bridge: 0000c000-0000efff
	Memory behind bridge: f0800000-f30fffff
	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: <access denied>

08:01.0 PCI bridge: Pericom Semiconductor Device 2404 (rev 05) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin ? routed to IRQ 35
	Bus: primary=08, secondary=09, subordinate=09, sec-latency=0
	I/O behind bridge: 0000e000-0000efff
	Memory behind bridge: f2800000-f30fffff
	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: <access denied>
	Kernel driver in use: pcieport

08:02.0 PCI bridge: Pericom Semiconductor Device 2404 (rev 05) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin ? routed to IRQ 36
	Bus: primary=08, secondary=0a, subordinate=0a, sec-latency=0
	I/O behind bridge: 0000d000-0000dfff
	Memory behind bridge: f1800000-f20fffff
	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: <access denied>
	Kernel driver in use: pcieport

08:03.0 PCI bridge: Pericom Semiconductor Device 2404 (rev 05) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin ? routed to IRQ 37
	Bus: primary=08, secondary=0b, subordinate=0b, sec-latency=0
	I/O behind bridge: 0000c000-0000cfff
	Memory behind bridge: f0800000-f10fffff
	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
	BridgeCtl: Parity- SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
		PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
	Capabilities: <access denied>
	Kernel driver in use: pcieport

09:00.0 Ethernet controller: Intel Corporation I211 Gigabit Network Connection (rev 03)
	Subsystem: Intel Corporation I211 Gigabit Network Connection
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 71
	Region 0: Memory at f2800000 (32-bit, non-prefetchable) [size=8M]
	Region 2: I/O ports at e000 [disabled] [size=32]
	Region 3: Memory at f3000000 (32-bit, non-prefetchable) [size=16K]
	Capabilities: <access denied>
	Kernel driver in use: igb
	Kernel modules: igb

0a:00.0 Ethernet controller: Intel Corporation I211 Gigabit Network Connection (rev 03)
	Subsystem: Intel Corporation I211 Gigabit Network Connection
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 77
	Region 0: Memory at f1800000 (32-bit, non-prefetchable) [size=8M]
	Region 2: I/O ports at d000 [disabled] [size=32]
	Region 3: Memory at f2000000 (32-bit, non-prefetchable) [size=16K]
	Capabilities: <access denied>
	Kernel driver in use: igb
	Kernel modules: igb

0b:00.0 Ethernet controller: Intel Corporation I211 Gigabit Network Connection (rev 03)
	Subsystem: Intel Corporation I211 Gigabit Network Connection
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 83
	Region 0: Memory at f0800000 (32-bit, non-prefetchable) [size=8M]
	Region 2: I/O ports at c000 [disabled] [size=32]
	Region 3: Memory at f1000000 (32-bit, non-prefetchable) [size=16K]
	Capabilities: <access denied>
	Kernel driver in use: igb
	Kernel modules: igb

0c:00.0 Bridge: Altera Corporation Device 203d (rev 04)
	Subsystem: Device 00b9:5a91
	Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Interrupt: pin A routed to IRQ 109
	Region 0: Memory at e8000000 (32-bit, non-prefetchable) [size=128M]
	Region 1: Memory at f0000000 (32-bit, non-prefetchable) [size=128K]
	Capabilities: <access denied>
	Kernel modules: altera_cvp

0d:00.0 Bridge: Altera Corporation Device 203d (rev 04)
	Subsystem: Device 00b9:5a91
	Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Interrupt: pin A routed to IRQ 110
	Region 0: Memory at d8000000 (32-bit, non-prefetchable) [size=128M]
	Region 1: Memory at e0000000 (32-bit, non-prefetchable) [size=128K]
	Capabilities: <access denied>
	Kernel modules: altera_cvp

0e:00.0 Non-Volatile memory controller: Device 1db2:2302 (rev 03) (prog-if 02 [NVM Express])
	Subsystem: Device 1db2:2302
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 61
	NUMA node: 0
	Region 0: Memory at f5a00000 (64-bit, non-prefetchable) [size=16K]
	Capabilities: <access denied>
	Kernel driver in use: nvme
	Kernel modules: nvme

0f:00.0 VGA compatible controller: Advanced Micro Devices, Inc. [AMD/ATI] Raven Ridge [Radeon Vega Series / Radeon Vega Mobile Series] (rev 83) (prog-if 00 [VGA controller])
	Subsystem: Advanced Micro Devices, Inc. [AMD/ATI] Vega [Radeon Vega 8 Mobile]
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort+ <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 107
	Region 0: Memory at c0000000 (64-bit, prefetchable) [size=256M]
	Region 2: Memory at d0000000 (64-bit, prefetchable) [size=2M]
	Region 4: I/O ports at f000 [size=256]
	Region 5: Memory at f5800000 (32-bit, non-prefetchable) [size=512K]
	Capabilities: <access denied>
	Kernel driver in use: amdgpu
	Kernel modules: amdgpu

0f:00.1 Audio device: Advanced Micro Devices, Inc. [AMD/ATI] Device 15de
	Subsystem: Advanced Micro Devices, Inc. [AMD/ATI] Device 15de
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin B routed to IRQ 105
	Region 0: Memory at f58c8000 (32-bit, non-prefetchable) [size=16K]
	Capabilities: <access denied>
	Kernel driver in use: snd_hda_intel
	Kernel modules: snd_hda_intel

0f:00.2 Encryption controller: Advanced Micro Devices, Inc. [AMD] Device 15df
	Subsystem: Advanced Micro Devices, Inc. [AMD] Device 15df
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Interrupt: pin C routed to IRQ 255
	Region 2: Memory at f5700000 (32-bit, non-prefetchable) [disabled] [size=1M]
	Region 5: Memory at f58ce000 (32-bit, non-prefetchable) [disabled] [size=8K]
	Capabilities: <access denied>

0f:00.3 USB controller: Advanced Micro Devices, Inc. [AMD] Device 15e0 (prog-if 30 [XHCI])
	Subsystem: Advanced Micro Devices, Inc. [AMD] Device 7914
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin D routed to IRQ 38
	Region 0: Memory at f5600000 (64-bit, non-prefetchable) [size=1M]
	Capabilities: <access denied>
	Kernel driver in use: xhci_hcd

0f:00.4 USB controller: Advanced Micro Devices, Inc. [AMD] Device 15e1 (prog-if 30 [XHCI])
	Subsystem: Advanced Micro Devices, Inc. [AMD] Device 7914
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 24
	Region 0: Memory at f5500000 (64-bit, non-prefetchable) [size=1M]
	Capabilities: <access denied>
	Kernel driver in use: xhci_hcd

0f:00.5 Multimedia controller: Advanced Micro Devices, Inc. [AMD] Device 15e2
	Subsystem: Advanced Micro Devices, Inc. [AMD] Device 15e2
	Control: I/O- Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Interrupt: pin B routed to IRQ 104
	Region 0: Memory at f5880000 (32-bit, non-prefetchable) [size=256K]
	Capabilities: <access denied>
	Kernel modules: snd_pci_acp3x, snd_rn_pci_acp3x

0f:00.6 Audio device: Advanced Micro Devices, Inc. [AMD] Device 15e3
	Subsystem: Advanced Micro Devices, Inc. [AMD] Device d001
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin C routed to IRQ 106
	Region 0: Memory at f58c0000 (32-bit, non-prefetchable) [size=32K]
	Capabilities: <access denied>
	Kernel driver in use: snd_hda_intel
	Kernel modules: snd_hda_intel

0f:00.7 Non-VGA unclassified device: Advanced Micro Devices, Inc. [AMD] Device 15e6
	Subsystem: Advanced Micro Devices, Inc. [AMD] Device 15e4
	Control: I/O- Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Interrupt: pin D routed to IRQ 38
	Region 2: Memory at f5400000 (32-bit, non-prefetchable) [size=1M]
	Region 5: Memory at f58cc000 (32-bit, non-prefetchable) [size=8K]
	Capabilities: <access denied>
	Kernel driver in use: i2c_amd_mp2
	Kernel modules: i2c_amd_mp2_pci

10:00.0 SATA controller: Advanced Micro Devices, Inc. [AMD] FCH SATA Controller [AHCI mode] (rev 61) (prog-if 01 [AHCI 1.0])
	Subsystem: Advanced Micro Devices, Inc. [AMD] FCH SATA Controller [AHCI mode]
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 64
	Region 5: Memory at f5900000 (32-bit, non-prefetchable) [size=2K]
	Capabilities: <access denied>
	Kernel driver in use: ahci
	Kernel modules: ahci
```

## **Step #3. Find the path from our F205 Carrier board to the master PCI Bus (00).**

As you know, the PCI Bridges are, basically, components that interconnect PCI Buses, so each PCI Bridge has connection with 2 PCI Buses.
They are called primary and secondary. So in our case, we have to do a backward search, from the Carrier board to the master PCI Bus (00)

Let's start! First, find our Carrier board in the list (06:0f.0)

```
06:0f.0 Bridge: Altera Corporation Device d203 (rev e3).
```

So, our Carrier board is connected to PCI bus 06.

Then, let's find a PCI Bridge which has a secondary bus with value 06

```
05:00.0 PCI bridge: Texas Instruments XIO2001 PCI Express-to-PCI Bridge (prog-if 00 [Normal decode])
	Bus: primary=05, secondary=06, subordinate=06, sec-latency=32
```

The PCI Bridge has the geographical address (05:00.0)

Then, keep searching! now, search a new PCI Bridge with a secondary bus with value 05

```
02:03.0 PCI bridge: Pericom Semiconductor Device 2404 (rev 05) (prog-if 00 [Normal decode])
	Bus: primary=02, secondary=05, subordinate=06, sec-latency=0
```

The PCI Bridge has the geographical address (02:03.0)

Continue... Now, search a new PCI Bridge with a secondary bus with value 02

```
01:00.0 PCI bridge: Pericom Semiconductor Device 2404 (rev 05) (prog-if 00 [Normal decode])
	Bus: primary=01, secondary=02, subordinate=06, sec-latency=0
```

The PCI Bridge has the geographical address (01:00.0)

Continue... Now, search a new PCI Bridge with a secondary bus with value 01

```
00:01.3 PCI bridge: Advanced Micro Devices, Inc. [AMD] Device 15d3 (prog-if 00 [Normal decode])
	Bus: primary=00, secondary=01, subordinate=06, sec-latency=0
```

And that is all, you have found the PCI Bridge connected to the master PCI Bus (has the geographical address 00:01.3).

## **Step #4. Create the PCI_BUS_PATH**

Now, once you have the list of PCI Bridges from the master PCI Bus, you have to order them from the master PCI Bus to
the Carrier Board, but you only have to put the PCI Bridges on the list, not the Carrier board.

```
00:01.3 PCI bridge: Advanced Micro Devices, Inc. [AMD] Device 15d3 (prog-if 00 [Normal decode])
01:00.0 PCI bridge: Pericom Semiconductor Device 2404 (rev 05) (prog-if 00 [Normal decode])
02:03.0 PCI bridge: Pericom Semiconductor Device 2404 (rev 05) (prog-if 00 [Normal decode])
05:00.0 PCI bridge: Texas Instruments XIO2001 PCI Express-to-PCI Bridge (prog-if 00 [Normal decode])
```

After that, you have to transform the data to the PCI_BUS_PATH format:

NOTE: The geographical address is composed, basically, with a 3-tuple (PCI Bus, Device Number, Function Number)

You have to apply, for each element in the list, the following operation

```
Device Number | (Function number << 5)
```

So:

```
00:01.3 PCI bridge: Advanced Micro Devices, Inc. [AMD] Device 15d3 (prog-if 00 [Normal decode])       -> (0x01 | 0x03 << 5) -> 0x61
01:00.0 PCI bridge: Pericom Semiconductor Device 2404 (rev 05) (prog-if 00 [Normal decode])           -> (0x00 | 0x00 << 5) -> 0x00
02:03.0 PCI bridge: Pericom Semiconductor Device 2404 (rev 05) (prog-if 00 [Normal decode])           -> (0x03 | 0x00 << 5) -> 0x03
05:00.0 PCI bridge: Texas Instruments XIO2001 PCI Express-to-PCI Bridge (prog-if 00 [Normal decode])  -> (0x00 | 0x00 << 5) -> 0x00
```

The PCI_BUS_PATH that you should put in the system.dsc file is:

```
PCI_BUS_PATH BINARY 0x61, 0x00, 0x03 , 0x00
```

## **Step #5. Complete the configuration**

According with the documentation, if you configure board without using PCI BUS & DEVICE NUMBER, besides using the PCI_BUS_PATH, you also have to add 2 more values. Such values are:

- PCI_BUS_SLOT
- PCI_DEVICE_ID

Let's remember the PCI geographical address of our F205 carrier board.

```
06:0f.0 Bridge: Altera Corporation Device d203 (rev e3).
```

The PCI_DEVICE_ID is the Device Number of the geographical address of the board, in this case it is 0x0f. The PCI_DEVICE_ID value is related with the slot in the backplane where the board is actually connected to and can be computed from the the PCI_DEVICE_ID following the table below:

| slot      |  2  |  3  |  4  |  5  |  6  |  7  |  8  |
|:---------:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **device id** | 0xf | 0xe | 0xd | 0xc | 0xb | 0xa | 0x9 |

So, in our case, as the PCI_DEVICE_ID is 0xf, the PCI_BUS_SLOT is 2

The final PCI configuration of the F205 in the system.dsc file is:

```
d203_1 {

    # ------------------------------------------------------------------------
    #        general parameters (don't modify)
    # ------------------------------------------------------------------------
    DESC_TYPE = U_INT32 0x2
    HW_TYPE = STRING D203
    _WIZ_MODEL = STRING F205
    _WIZ_BUSIF = STRING cpu,1

    # ------------------------------------------------------------------------
    #        PCI configuration
    # ------------------------------------------------------------------------
    PCI_BUS_PATH = BINARY 0x61, 0x00, 0x03, 0x00
    PCI_BUS_SLOT = U_INT32 0x2
    PCI_DEVICE_ID = U_INT32 0xf

    # ------------------------------------------------------------------------
    #        debug levels (optional)
    #        these keys have only effect on debug drivers
    # ------------------------------------------------------------------------
    DEBUG_LEVEL = U_INT32 0xc0008000
    DEBUG_LEVEL_BK = U_INT32 0xc0008000
    DEBUG_LEVEL_OSS = U_INT32 0xc0008000
    DEBUG_LEVEL_DESC = U_INT32 0xc0008000
}
```