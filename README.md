# MDIS test system
This is description of the automated test system for MDIS.

mdis_test_system repository provides scripts to easily test behaviour of MEN hardware/software on different operating systems and kernels for tests setups specified for mdis release 13MD05-90_02_02. 

Shortened functional test usage description:
1. Prepare and configure OS-es on external drive (ssd USB 3 drive shall be considered), that can be connected to MEN CPU boards
2. Prepare MEN hardware (Test setup <1-10> and BOXPC BL51E - if relay is necessary)
3. Configure test system (please follow "Test script configuration" section)
4. Run main test script ./Mdis_Test.sh with proper params and wait for the results
5. Generate results in user friendly format with Mdis_Report.sh script

Please check MDIS test system scheme :

![mdis_test_system_scheme](https://github.com/MEN-Mikro-Elektronik/mdis_test_system/blob/jpe-dev-02_02/Images/mdis_test_system.png)

Shortened compilation test usage:
1. Download and unzip kernel sources you would like to use (https://www.kernel.org/),
2. Download MDIS repository,
3. Run compilation tests to check MDIS compatibility.

Please find detailed ussage description in proper sections.

# Functional tests
To run automated functional tests please prepare below equipment:
- Target - MEN hardware in proper configuration - Test setup <1-10>
- Host - Computer with Linux OS that will run tests on Target
- Relay - to enable/disable modules inputs - MEN Box PC BL51 is used

Functional tests sources consist of directories:
- Common - common part used by Target, Host (Configuration file)
- Host - part used by Host (Scripts to communicate with Target and Relay that controls the test process)
- Target - part used by Target (Description of test cases and hardware configuration)

## Preparing disk and OS configuration

### Disk partitioning
Disk should be partitioned like below
- GPT partition table
  - 10 GB partition for data files (ext4)
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

### OSes support and configuration
Following OSes are supported:
- Ubuntu
  - 18.04.3 32-bit
  - 18.04.3 64-bit
  - 20.04 64-bit
- Debian
  - 10 32-bit
  - 10 64-bit
- Centos
  - 7 64-bit
  - 8 64-bit


The system should be configured as it is described below. It applies to all OSes (Ubuntu, CentOS etc.). For some of them special action is required.

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
- Ubuntu, CentOS:
```
# visudo
Defaults env_reset
Defaults env_reset, timestamp_timeout=0
```

6. Allow to log in as root via ssh,
- CentOS:
Make sure that password for root is "men". During install CentOS require password to be at least 8 characters.
- Ubuntu:
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

8. Install ansible:
- Ubuntu
```
# apt-get update
# apt-get install software-properties-common
# apt-add-repository --yes --update ppa:ansible/ansible
# apt-get install ansible
```

9. Run ansible playbook on Host PC that will run tests
Check if addresses of devices are correct in inventory file
```ansible-playbook -i inventory playbook.yml```
To add new packages to install edit ```roles/defaults/main.yml```

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
# Run tests on setup 1 on all OS-es with verbose output 
# ./Mdis_Test.sh --run-setup=1 --verbose=1
# Run tests on setup 1 on OS that is currently running on Target machine
# ./Mdis_Test.sh --run-instantly --run-setup=1
```

# Compilation tests
Compilation test part is located in ```MDIS_Compilation_Test``` directory.

## Test script configuration
Most important variables that have to be set in configuration file ```MDIS_Compilation_Test/Conf.sh```

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

  Path to directory with kernel sources. All Linux kernels should be placed in this direcotry.
  
  e.g.:
  ```LinuxKernelsDirectoryPath="/media/tests/LinuxKernels"```

## Kernel list for testing
The list of kernels used for testing should be placed in ``` MDIS_Compilation_Tests/kernel_list_release_02.txt```
e.g.:
```
3.16.83
4.4.221
4.9.221
4.14.178
4.19.120
5.4.38
5.5.19
```

## Running compilation tests
When everything is set up just run the script:
```
# MDIS_Compilation_Tests/run_buildtest.sh --download --all
```
