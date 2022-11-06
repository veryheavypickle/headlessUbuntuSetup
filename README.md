# headlessUbuntuSetup
This is the complete config of my home server, it is very specific to me and I take note of every change I make so I can easily reconstruct this setup. In my host, I try to install as little packages as possible so I can have as close to fresh as possible. My motherboard allows me to boot without having a GPU connected. However the GPU was necesessary to setup the BIOS and Ubuntu.

Hardware
--------
```
CPU: Ryzen 9 3900X
GPU: Radeon RX 5500 XT 8GB
RAM: Corsair Vengeance LPX 32GB
Motherboard: Gigabyte X570 I AORUS PRO WiFi
Cooling: Corsair Hydro H60 2018
```

Software
--------
```
OS: 22.04.1 LTS
```
This is specified in `install.sh`

BIOS Setup
----------
```
CPU Vcore [0.93750V]
Extreme Memory profile [Profile1]
SVM Mode [Enabled]
IOMMU [Enabled]
CPU_Fan Speed [Manual]
CPU_Fan Stop [Enabled]
Sys_Fan1 Speed Control [Silent]
CSM [Disabled]
```

### Fan curve
At the undervolt I have, this is sufficient since the watercooler pump always runs at 100%.
```
30°C: 0%
40°C: 10%
50°C: 20%
65°C: 100%
```

Headless Setup
--------------
## Setup for AMD and NVIDIA GPUs on Intel or AMD CPUs
With help from [KVM GPU Passthrough](https://bananaapple.tw/blog/kvm-gpu-passthrough-ubuntu-20-04/)  and [OSX-KVM](https://github.com/kholia/OSX-KVM/blob/master/notes.md) I can set up the changes necessasary to pass the GPU to a VM. I have modified these instructions for an AMD GPU but have included the original an NVIDIA GPU too.


## Enable IOMMU
### In BIOS
Boot into BIOS and set IOMMU to Enabled and CSM to Disabled

### Configure GRUB
Edit `/etc/default/grub`
For an Intel CPU
```
GRUB_CMDLINE_LINUX_DEFAULT="iommu=pt intel_iommu=on"
```
For an AMD CPU
```
GRUB_CMDLINE_LINUX_DEFAULT="iommu=pt amd_iommu=on"
```

### Update GRUB
`sudo update-grub`

### Reboot
`sudo reboot`

### Verify IOMMU is enabled
`sudo dmesg | grep IOMMU`

Output without GPU connected
```
[    0.264796] pci 0000:00:00.2: AMD-Vi: IOMMU performance counters supported
[    0.265662] pci 0000:00:00.2: AMD-Vi: Found IOMMU cap 0x40
[    0.266137] perf/amd_iommu: Detected AMD IOMMU #0 (2 banks, 4 counters/bank).
```

Output with GPU connected
```
[    0.265787] pci 0000:00:00.2: AMD-Vi: IOMMU performance counters supported
[    0.266951] pci 0000:00:00.2: AMD-Vi: Found IOMMU cap 0x40
[    0.267833] perf/amd_iommu: Detected AMD IOMMU #0 (2 banks, 4 counters/bank).
[    3.119906] AMD-Vi: AMD IOMMUv2 loaded and initialized
```

Check which groups there are
```
for a in /sys/kernel/iommu_groups/*; do find $a -type l; done | sort --version-sort
```
Output should be something like
```
/sys/kernel/iommu_groups/0/devices/0000:00:00.0
/sys/kernel/iommu_groups/1/devices/0000:00:04.0
/sys/kernel/iommu_groups/2/devices/0000:00:04.1
/sys/kernel/iommu_groups/3/devices/0000:00:04.2
/sys/kernel/iommu_groups/4/devices/0000:00:04.3
```

**For the remainder of this, I left the GPU connected.**

## Using vfio-pci to manage PCI device
This will show all the VGA controllers - ie. video cards (AMD or NVIDIA) `lspci -nn | grep -i VGA`
```
0a:00.0 VGA compatible controller [0300]: Advanced Micro Devices, Inc. [AMD/ATI] Navi 14 [Radeon RX 5500/5500M / Pro 5500M] [1002:7340] (rev c5)
```

Show USB controllers, as I will probably need USB `lspci -nn | grep -i USB`
```
05:00.1 USB controller [0c03]: Advanced Micro Devices, Inc. [AMD] Matisse USB 3.0 Host Controller [1022:149c]
05:00.3 USB controller [0c03]: Advanced Micro Devices, Inc. [AMD] Matisse USB 3.0 Host Controller [1022:149c]
0c:00.3 USB controller [0c03]: Advanced Micro Devices, Inc. [AMD] Matisse USB 3.0 Host Controller [1022:149c]
```

Show all the Audio controllers for AMD `lspci -nn | grep Audio`. I am assuming I need the HDMI sound as a seperate device.
```
0a:00.1 Audio device [0403]: Advanced Micro Devices, Inc. [AMD/ATI] Navi 10 HDMI Audio [1002:ab38]
0c:00.4 Audio device [0403]: Advanced Micro Devices, Inc. [AMD] Starship/Matisse HD Audio Controller [1022:1487]
```

Data for the GPU
```
PCI ID: 0a:00.0
Vendor ID: 1002
Device ID: 7340
```

Data for a last USB controller
```
PCI ID: 0c:00.3
Vendor ID: 1022
Device ID: 149c
```

Data for HDMI audio controller
```
PCI ID: 0c:00.4
Vendor ID: 1002
Device ID: ab38
```

### Configure GRUB
`/etc/default/grub`
Apply all the audio and VGA devices plus extra arguments
```
GRUB_CMDLINE_LINUX_DEFAULT="iommu=pt amd_iommu=on vfio-pci.ids=1002:7340,1002:ab38,1022:149c kvm.ignore_msrs=1 video=vesafb:off,efifb:off"
```
In my case, I had an issue with `vfio_region_write device or resource busy`, I fixed this by removing the option `vesafb:off` from above.

### Blacklist drivers
At the end of `/etc/modprobe.d/blacklist.conf`, add
```
blacklist amdgpu
blacklist radeon
```

### Edit VFIO config
I am not sure if this is necessary. In `/etc/modprobe.d/vfio.conf`. Change the following settings (if the file exits at all!)
```
options vfio-pci ids=1002:67df,1002:aaf0 disable_vga=1
softdep radeon pre: vfio-pci
softdep amdgpu pre: vfio-pci
softdep nouveau pre: vfio-pci
softdep drm pre: vfio-pci
```

### Update GRUB
`sudo update-grub`
`sudo update-initramfs -k all -u`

### Reboot
`sudo reboot`

When rebooted, the screen should freeze. Before this, I hope you set up an SSH connection, I should have mentioned this before lol

### Verify PCI device is managed by vfio-pci
`lspci -nnv`

Scroll down to the line beginning with your PCI ID
```
0a:00.0 VGA compatible controller [0300]: Advanced Micro Devices, Inc. [AMD/ATI] Navi 14 [Radeon RX 5500/5500M / Pro 5500M] [1002:7340] (rev c5) (prog-if 00 [VGA controller])
        Subsystem: Tul Corporation / PowerColor Navi 14 [Radeon RX 5500/5500M / Pro 5500M] [148c:2401]
        Flags: bus master, fast devsel, latency 0, IRQ 10, IOMMU group 23
        Memory at d0000000 (64-bit, prefetchable) [size=256M]
        Memory at e0000000 (64-bit, prefetchable) [size=2M]
        I/O ports at e000 [size=256]
        Memory at fce00000 (32-bit, non-prefetchable) [size=512K]
        Expansion ROM at 000c0000 [disabled] [size=128K]
        Capabilities: <access denied>
        Kernel driver in use: vfio-pci
        Kernel modules: amdgpu

0a:00.1 Audio device [0403]: Advanced Micro Devices, Inc. [AMD/ATI] Navi 10 HDMI Audio [1002:ab38]
        Subsystem: Tul Corporation / PowerColor Navi 10 HDMI Audio [148c:2401]
        Flags: bus master, fast devsel, latency 0, IRQ 4, IOMMU group 24
        Memory at fcea0000 (32-bit, non-prefetchable) [size=16K]
        Capabilities: <access denied>
        Kernel driver in use: vfio-pci
        Kernel modules: snd_hda_intel
```

macOS VM
--------

With help from [these notes](https://github.com/kholia/OSX-KVM/blob/master/notes.md) and the setup from [OSX-KVM](https://github.com/kholia/OSX-KVM). I was able to create this.

### Install necessary packages 
```
sudo apt-get install qemu uml-utilities virt-manager git \
    wget libguestfs-tools p7zip-full make dmg2img -y
```


### Clone OSX-KVM
```
git clone --depth 1 --recursive https://github.com/kholia/OSX-KVM.git
cd OSX-KVM
```

### Download macOS
In this case, I went with the reccomendation
```
./fetch-macOS-v2.py
```

### Configure disk
```
dmg2img -i BaseSystem.dmg BaseSystem.img
qemu-img create -f qcow2 mac_hdd_ng.img 128G
```

### Edit config to allow passthrough
Change the USB, GPU and GPU audio addresses to the ones found above in `boot-passthrough.sh` .

### Run the VM
```
sudo ./boot-passthrough.sh
```
When running this, I got to the drive picker screen, but then got a blackscreen afterwards. The OSX-KVM notes reccomend to first run the macOS installer using `OpenCore-Boot.sh` then booting into the finished install using `./boot-passthrough.sh`. I will try to do this on a linux mint virtual machine on my laptop. VM inception time.

The [OSX-KVM Guide](https://github.com/kholia/OSX-KVM) reccomends to use a non-APFS filesystem. In my case this didn't work. As I have setup a bare metal OpenCore machine in the past and have read the current [OpenCore documentaion](https://caizhiyuan.gitee.io/opencore-install-guide/installation/installation-process.html#booting-the-opencore-usb) I found it was reccomended to use an APFS file-system.
