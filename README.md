# headlessUbuntuSetup
This is the complete config of my home server, it is very specific to me and I take note of every change I make so I can easily reconstruct this setup. In my host, I try to install as little packages as possible so I can have as close to fresh as possible. My motherboard allows me to boot without having a GPU connected. However the GPU was necesessary to setup the BIOS and Ubuntu.

Hardware
--------
**CPU:** Ryzen 9 3900X
**GPU:** Radeon RX 5500 XT 8GB
**RAM:** Corsair Vengeance LPX 32GB
**Motherboard:** Gigabyte X570 I AORUS PRO WiFi
**Cooling:** Corsair Hydro H60 2018

Software
--------
**OS: ** 22.04.1 LTS
This is specified in `install.sh`

BIOS Setup
----------
`CPU Vcore [0.93750V]`
`Extreme Memory profile [Profile1]`
`SVM Mode [Enabled]`
`IOMMU [Enabled]`
`CPU_Fan Speed [Manual]`
`CPU_Fan Stop [Enabled]`
`Sys_Fan1 Speed Control [Silent]`

### Fan curve
At the undervolt I have, this is sufficient since the watercooler pump always runs at 100%.
```
30°C: 0%
40°C: 10%
50°C: 20%
65°C: 100%
```

Headless
--------
With help from [KVM GPU Passthrough](https://bananaapple.tw/blog/kvm-gpu-passthrough-ubuntu-20-04/) I can set up the changes necessasary to pass the GPU to a VM.
I will make a copy of the instructions above incase the site no longer exists when I need it.

### Enable IOMMU
Edit `/etc/default/grub`
```
# Intel CPU
GRUB_CMDLINE_LINUX_DEFAULT="intel_iommu=on"
# AMD CPU
GRUB_CMDLINE_LINUX_DEFAULT="amd_iommu=on iommu=pt kvm_amd.npt=1 kvm_amd.avic=1"
```

### Update GRUB
`sudo update-grub`

### Reboot
`sudo shutdown now`
