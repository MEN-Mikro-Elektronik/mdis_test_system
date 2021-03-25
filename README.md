# MDIS test system
This is description of the automated test system for MDIS.

mdis_test_system repository provides scripts to easily test behaviour of MEN hardware/software on different operating systems and kernels for test setups specified for MDIS release 13MD05-90_02_04. 

Shortened functional test usage description:
1. Prepare and configure OSs on external drive (SSD USB 3.0 drive shall be considered), that can be connected to MEN CPU boards
2. Prepare MEN hardware (Test setup <1-n>, Box PC BL51E, 12V power supply)
3. Configure test system (please follow "Test script configuration" section)
4. Run main test script ./Mdis_Test.sh with proper params and wait for the results
5. Generate results in user friendly format with Mdis_Report.sh script

Please check MDIS test system scheme :

![mdis_test_system_scheme](https://github.com/MEN-Mikro-Elektronik/mdis_test_system/blob/jpe-dev-02_02/Images/mdis_test_system.png)

Shortened compilation test usage:
1. Download and unzip kernel sources you would like to use (https://www.kernel.org/),
2. Download MDIS repository,
3. Run compilation tests to check MDIS compatibility.

Please find detailed usage description in proper sections.

# Functional tests
To run automated functional tests please prepare below equipment:
- Host - Computer with Linux OS that will run tests on Target
- Target - MEN hardware in proper configuration - Test setup <1-n>
- Relay - to enable/disable modules inputs - MEN Box PC BL51
- 12V power supply
- SSD drive with preinstalled and configured OSs. 

Functional tests sources consist of directories:
- Common - common part used by Target, Host (Configuration file)
- Host - part used by Host (Scripts to communicate with Target and Relay that controls the test process)
- Target - part used by Target (Description of test cases and hardware configuration)

## Preparing disk and OS configuration

### Disk partitioning
Disk should be partitioned like below
- GPT partition table
  - 20 GB partition for data files (ext2)
  - 10 GB swap partition
  - 512 MB EFI partition
  - 512 MB BIOS partition
  - 10 GB main OS partition (ext4)
  - ... other OS partitions (ext4)

### Preparing GRUB on main OS parition
To boot a particular OS with GRUB we need to make GRUB read configuration from file at run time. Follow below steps in order to do that.

1. GRUB script
Create the grub script file ```/etc/grub.d/99_men```.
Add executable permisions to the file:
```# chmod a+x /etc/grub.d/99_men```
Add this content to the file:
```
#!/usr/bin/env bash

UUID=e8dca0bb-40f4-4f46-84d5-5db6caad5f50
CONF=boot.cfg

cat <<EOF
insmod ext2
search --set data --fs-uuid ${UUID}
if [ -f (\$data)/${CONF} ]; then
        source (\$data)/${CONF}
fi
EOF
```
The **UUID** variable is the partition UUID where the configuration file is located. Use ```blkid``` to find a partition.
The **CONF** variable is the path to the configuration file on **UUID** partition.

2. GRUB flat menu
Open ```/etc/default/grub``` file.
Add this line to the file:
```GRUB_DISABLE_SUBMENU=y```

3. GRUB configuration file
Create the configuration file ```/media/tests/boot.cfg```.
Add this content to the file:
```
set timeout_style=menu
set timeout=10
set default="0"
```
The **timeout_style** variable is a style of boot. Set it to menu to show the menu or set it to hidden to hide the menu.
The **timeout** variable is a timeout in seconds after the OS is booted. Set it to ```-1``` to disable timeout or set it to ```0``` to boot immediately.
The default variable is the name of the OS to boot. It is the name of a menu entry.

4. Update GRUB
Update GRUB configuration:
```# update-grub```

### OS support and configuration
Following OSs are supported:
- Ubuntu
  - 18.04.3 32-bit
  - 18.04.3 64-bit
  - 20.04 64-bit
- Debian
  - 10.5 32-bit
  - 10.5 64-bit
  - 10.6 32-bit
  - 10.6 64-bit
- Centos
  - 7.8 64-bit
  - 8.2 64-bit


The system should be configured as it is described below. It applies to all OSs (Ubuntu, CentOS etc.). For some of them special action is required.

1. Disable automatic update,
- CentOS:
  To check if updates are turned on:
  ```# systemctl status packagekit```
  To disable updates:

```
# systemctl stop packagekit
# systemctl mask packagekit
```

2. Check if network interface is enabled after power on by default (on CentOS it is not),

3. Check if /usr/local/bin is added to secure_path (on CentOS it is not),
```
# visudo
Defaults secure_path=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin
```

4. Check time,
- CentOS:
  Install and use ntp:
```
# yum install ntp
# chkconfig ntpd on
# ntpdate pool.ntp.org
# service ntpd start
```

5. Set to ask sudo password every time,
- Ubuntu, CentOS, Debian:
```
# visudo
Defaults env_reset
Defaults env_reset, timestamp_timeout=0
```

6. Allow to log in as root via ssh,
- CentOS:
Make sure that password for root is "men". During install CentOS require password to be at least 8 characters.
- Ubuntu, Debian:
Open: /etc/ssh/sshd_config 
Add just below line: 
```
PermitRootLogin without-password
PermitRootLogin yes
```
Set root password:
```sudo passwd```
Restart SSH service
```sudo service ssh restart```

7. Below packages have to be installed on system:
    - python
    - openssh-server
    - sshpass
    - libelf-dev
    - bison
    - flex
    - libssl-dev
    - pppd
    - net-tools
    - rsync

## Test script configuration
Most important variables that have to be set in configuration file ```Common/Conf.sh```

- MenPcIpAddr

  IP address of test computer
  
  e.g.:
  ```MenPcIpAddr="192.168.1.100"```

- MenPcLogin

  Username of test user account on test computer
  
  e.g.:
  ```MenPcLogin="men"```

- MenPcPassword

  Password of test user account on test computer
  
  e.g.:
  ```MenPcPassword="men"```

- MenBoxPcIpAddr (relay)

  IP address of auxiliary Box PC BL51E
  
  e.g.:
  ```MenBoxPcIpAddr="192.168.1.200"```

- GitTestSourcesBranch

  Name of the test sources branch used for testing
  
  e.g.:
  ```GitTestSourcesBranch="master"```

- GitMdisBranch

  Name of the MDIS branch used for testing
  
  e.g.:
  ```GitMdisBranch="master"```

- MainTestDirectoryPath

  Path to directory where all test data is kept. It should be accessible on all test OSes
  
  e.g.:
  ```MainTestDirectoryPath="/media/tests"```

- GrubConfFile

  Path to GRUB configuration file
  
  e.g.:
  ```GrubConfFile="/media/tests/boot.cfg"```

- GrubOsesF26L
- GrubOsesF23P
- GrubOsesG23
- GrubOsesG25A
- GrubOsesBL50
- GrubOsesBL51E
- GrubOsesBL70

  List of names of operating systems used for testing on CPU board
  "0" is default OS and is not used for testing but should be present anyhow.
  
  e.g.:
  ```GrubOsesF26L=("0" "Ubuntu, with Linux 4.15.0-45-generic (on /dev/sda14)")```
  

## Running functional tests
When everything is set up, please move to mdis_test_system/Host/Mdis_Test directory and run test script with proper options:
```
# Print help
# ./Mdis_Test.sh --help
# Run tests on setup 1 on all OSs with verbose output 
# ./Mdis_Test.sh --run-setup=1 --verbose=1
# Run tests on setup 1 on OS that is currently running on Target machine
# ./Mdis_Test.sh --run-instantly --run-setup=1
```

# Compilation tests
Compilation test part is located in ```MDIS_Compilation_Test``` directory.

## OS setup

Below packages have to be installed on system:

- git
- build-essential
- flex
- bison
- libelf-dev, libelf-devel or elfutils-libelf-devel

Linux kernel sources should be placed in ```LinuxKernelsDirectoryPath``` directory and should not be compressed e.g.:
```
men@men:/media/tests/Linux_Kernels$ tree -L 1
.
├── linux-3.16.85
├── linux-4.14.216
├── linux-4.19.168
├── linux-4.4.252
├── linux-4.9.252
├── linux-5.10.8
├── linux-5.4.90
└── linux-5.6.19

8 directories, 0 files
```

## Test script configuration
Most important variables that have to be set in configuration file ```Conf.sh```

- GitMdisBranch

  Name of the MDIS branch used for testing
  
  e.g.:
  ```GitMdisBranch="master"```

- MenPcPassword

  Password of test user account on test computer
  
  e.g.:
  ```MenPcPassword="men"```

- MainTestDirectoryPath

  Path to directory where all test data is kept
  
  e.g.:
  ```MainTestDirectoryPath="/media/tests"```

- LinuxKernelsDirectoryPath

  Path to directory with kernel sources. All Linux kernels should be placed in this direcotry 
  
  e.g.:
  ```LinuxKernelsDirectoryPath="/media/tests/Linux_Kernels"```

## Kernel list for testing
The list of kernels used for testing should be placed in ``` kernel_list_release_02.txt```
e.g.:

```
3.16.85
4.4.252
4.9.252
4.14.216
4.19.168
5.4.90
5.6.19
5.10.8
```

## Running compilation tests

```
Compilation tests include testing of proprietary drivers 13M057-06 and 13M065-06 that are not public.
If you don't have source code for these drivers remove Makefile.13M057-06 and Makefile.13M065-06 from Makefiles directory to not test them.
```

When everything is set up just run the script:
```
# ./run_buildtest.sh --download --all
```

### Running compilation tests faster
In order to make compilation tests faster you can use one Makefile for tests:
```
# ./run_buildtest.sh --download --all --makefile Makefile.shared
```
```
# ./run_buildtest.sh --download --all --makefile Makefile.static
```
You must run ./create_makefile.sh to create both Makefiles 
