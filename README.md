# headlessUbuntuSetup
This is a script I use to setup ubuntu headless servers.

### Minimum packages
I try to install as little packages as possible

### Setup a GPU passthrough
https://bananaapple.tw/blog/kvm-gpu-passthrough-ubuntu-20-04/


Hadrware
--------
**CPU:** Ryzen 9 3900X
**GPU:** Radeon RX 5500 XT 8GB
**RAM:** Corsair Vengeance LPX 32GB
**Motherboard:** Gigabyte X570 I AORUS PRO WiFi
**Cooling:** Corsair Hydro H60 2018

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
