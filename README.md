# Test OS configuration

## Preparing GRUB
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

## OS configuration
The system should be configured as it is described below.

1. Disable automatic update,
CentOS:
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
CentOS:
Install and use ntp:
```
# yum install ntp
# chkconfig ntpd on
# ntpdate pool.ntp.org
# service ntpd start
```

5. Set to ask sudo password every time,
Ubuntu, CentOS:
```
# visudo
Defaults env_reset
Defaults env_reset, timestamp_timeout=0
```

6. Allow to log in as root via ssh,
CentOS:
Make sure that password for root is "men". During install CentOS require password to be at least 8 characters.
Ubuntu:
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

8. Run ansible playbook on Jenkins/Remote PC that will run tests:
Installing ansible:
```
# apt-get update
# apt-get install software-properties-common
# apt-add-repository --yes --update ppa:ansible/ansible
# apt-get install ansible
```
Check if addresses of devices are correct in inventory file
```ansible-playbook -i inventory playbook.yml```
To add new packages to install edit roles/defaults/main.yml

# Test script configuration
Most important variables that have to be set in configuration file "Common/Conf.sh"

- MenPcIpAddr
  IP address of test computer
  e.g.:
  ```MenPcIpAddr="192.168.1.100"```

- TestSetup
  Test configuration number
  e.g.:
  ```TestSetup="1"```

- MenPcLogin
  Username of test user account on test computer
  e.g.:
  ```MenPcLogin="men"```

- MenPcPassword
  Password of test user account on test computer
  e.g.:
  ```MenPcPassword="men"```

- MenBoxPcIpAddr
  IP address of auxiliary Box PC computer
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
  List of names of operating systems used for testing on F26L.
  "0" is default OS and is not used for testing but should be present anyhow.
  e.g.:
  ```GrubOsesF26L=("0" "Ubuntu, with Linux 4.15.0-45-generic (on /dev/sda14)")```

- GrubOsesF23P
  List of names of operating systems used for testing on F23P.
  "0" is default OS and is not used for testing but should be present anyhow.
  e.g.:
  ```GrubOsesF23P=("0" "Ubuntu, with Linux 4.15.0-45-generic (on /dev/sda14)")```

- GrubOsesG23
  List of names of operating systems used for testing on G23.
  "0" is default OS and is not used for testing but should be present anyhow.
  e.g.:
  ```GrubOsesG23=("0" "Ubuntu, with Linux 4.15.0-45-generic (on /dev/sda14)")```

- GrubOsesG25A
  List of names of operating systems used for testing on G25A.
  "0" is default OS and is not used for testing but should be present anyhow.
  e.g.:
  ```GrubOsesG25A=("0" "Ubuntu, with Linux 4.15.0-45-generic (on /dev/sda14)")```

- GrubOsesBL51E
  List of names of operating systems used for testing on BL51E.
  "0" is default OS and is not used for testing but should be present anyhow.
  e.g.:
  ```GrubOsesBL51E=("0" "Ubuntu, with Linux 4.15.0-45-generic (on /dev/sda14)")```

# Running tests
When everything is set up just run the script:
```
# Host/Jenkins/Jenkins.sh
```