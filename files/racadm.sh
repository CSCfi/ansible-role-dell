#!/bin/bash

# Time saver for racadm commands - to manage remote hosts' iDRAC interface
# Command Reference guide is called 
# "Integrated Dell Remote Access Controller 8 (iDRAC8) Version 2.00.00.00 RACADM Command Line Interface Reference Guide"

usage () {
  echo "racadm helper script"
  echo "_Many_ commands have hardcoded settings in the script"
  echo "Modify the script to your liking"
  echo "Usage: $0 <host> <command>"
  echo
  echo "export IPMI_USERNAME=admin_username"
  echo "export IPMI_PASSWORD=admin_user_password"
  echo "host: hostname or IP address of controller"
  echo "command: <native racadm command> e.g. help"
  echo "Commands: "
  echo  "  * - run what was passed to the script"
  echo  "  adminuser - adds an adminuser"
  echo  "  bootdisk - boot from disk"
  echo  "  bootnet - boot from net"
  echo  "  bootnormal - boot from normal"
  echo  "  bootonce - enable bootonce"
  echo  "  disableled - disable led"
  echo  "  disabletelnet - disable telnet"
  echo  "  email - configure e-mail"
  echo  "  enableserial - enables serial"
  echo  "  getled - get led status"
  echo  "  getsel - get SEL"
  echo  "  getxml - get XML complete config"
  echo  "  graceshutdown"
  echo  "  hardreset"
  echo  "  help - show racadm help"
  echo  "  location - set location"
  echo  "  ntp - configure NTP"
  echo  "  powercycle"
  echo  "  powerdown"
  echo  "  powerstatus"
  echo  "  powerup"
  echo  "  rouser - add a readonlyuser"
  echo  "  setled - enable led"
  echo  "  setxml - configure XML from a file /tmp/<host>-set.xml"
  echo  "  syslog - configure sending syslog to a remote server"
  exit ${RC:-2}
}

# Only check we have 2 or more agruments
[ $# -ge 2 ] || usage

adminuser=$IPMI_USERNAME
password=$IPMI_PASSWORD
host=$1
shift
command=$*
raccmd="/opt/dell/srvadmin/sbin/racadm -r $host -u $adminuser -p $password --nocertwarn"

## Some safety checks
if [ ! -f "/opt/dell/srvadmin/sbin/racadm" ]; then
	echo "Error: /opt/dell/srvadmin/sbin/racadm is not found"
fi
if [ "$IPMI_USERNAME" == "" ]; then
	echo "Error: IPMI_USERNAME is not set"
fi
if [ "$IPMI_PASSWORD" == "" ]; then
	echo "Error: IPMI_PASSWORD is not set"
fi
##

case "$command" in
  getxml)
    # Get the xml config
    $raccmd get -t xml -f /tmp/$host.xml
    echo "xml location /tmp/$host.xml"
    ;;
  setxml)
    # Set the xml config
    echo "xml set with /tmp/$host-set.xml"
    $raccmd set -t xml -f /tmp/$host-set.xml
    ;;
  bootonce)
    # Enable bootonce
    $raccmd set iDRAC.ServerBoot.BootOnce 1
    ;;
  bootnet)
    # Set bootonce to net
    $raccmd set iDRAC.ServerBoot.FirstBootDevice PXE
    ;;
  bootdisk)
    # Boot from the disk
    $raccmd set iDRAC.ServerBoot.FirstBootDevice HDD
    ;;
  bootnormal)
    # Normal Boot Sequence
    $raccmd set iDRAC.ServerBoot.FirstBootDevice Normal
    ;;
  hardreset)
    $raccmd serveraction hardreset
    ;;
  powercycle)
    $raccmd serveraction powercycle
    ;;
  powerdown)
    $raccmd serveraction powerdown
    ;;
  powerup)
    $raccmd serveraction powerup
    ;;
  powerstatus)
    $raccmd serveraction powerstatus
    ;;
  graceshutdown)
    $raccmd serveraction graceshutdown
    ;;
  rouser)
    # Add a read-only user
    $raccmd set iDRAC.Users.4.UserName User1
    # echo -n "foobar"|sha256sum
    $raccmd set iDRAC.Users.4.SHA256Password 149a1dad82531ca1e15ad7751604bf5e8da7ba86a1c92c91dc6ab697ce6d9413
    $raccmd set iDRAC.Users.4.IpmiLanPrivilege 2
    $raccmd set iDRAC.Users.4.IpmiSerialPrivilege 2
    $raccmd set iDRAC.Users.4.SolEnable 0
    $raccmd set iDRAC.Users.4.Privilege 0x1
    $raccmd set iDRAC.Users.4.Enable 1
    ;;
  adminuser)
    # Add another user
    $raccmd set iDRAC.Users.6.UserName Admin1
    # echo -n "foobar"|sha256sum
    $raccmd set iDRAC.Users.6.SHA256Password 149a1dad82531ca1e15ad7751604bf5e8da7ba86a1c92c91dc6ab697ce6d9413
    $raccmd set iDRAC.Users.6.IpmiLanPrivilege 4
    $raccmd set iDRAC.Users.6.IpmiSerialPrivilege 4
    $raccmd set iDRAC.Users.6.SolEnable 1
#    $raccmd set iDRAC.Users.6.SNMPv3Enable 1
    $raccmd set iDRAC.Users.6.Privilege 0x000001ff
    $raccmd set iDRAC.Users.6.Enable 1
    ;;
  location)
    # Set some server descriptions
    $raccmd set System.Location.Aisle X
    $raccmd set System.Location.DataCenter CSC Kajaani
    $raccmd set System.Location.Rack.Name Y
    $raccmd set System.Location.Rack.Slot Z
    $raccmd set System.Location.RoomName Z
    ;;
  email)
    # Configure e-mail notifications
    $raccmd set iDRAC.EmailAlert.Address changeme@example.com
    $raccmd set iDRAC.EmailAlert.CustomMsg "From $host"
    $raccmd set iDRAC.EmailAlert.Enable 1
    $raccmd set iDRAC.RemoteHostSMTPServerIPAddress "smtpserverIP"
    ;;
  syslog)
    # Configure remote logging
    $raccmd set iDRAC.syslog.SysLogEnable 1
    $raccmd set iDRAC.syslog.Server1 "10.1.1.1"
    #$raccmd set iDRAC.syslog.PowerLogEnable 1
    ;;
  ntp)
    $raccmd set iDRAC.NTPConfigGroup.NTP1 10.1.1.1
    $raccmd set iDRAC.NTPConfigGroup.NTP1 10.1.1.2
    $raccmd set iDRAC.NTPConfigGroup.NTPEnable 1
    $raccmd set iDRAC.Time.Timezone "Europe/Helsinki"
    ;;
  enableserial)
    $raccmd set iDRAC.Serial.Enable 1
    ;;
  disabletelnet)
    $raccmd set iDRAC.Telnet.Enable 0
    ;;
  getsel)
    $raccmd getsel
    ;;
  getled)
    $raccmd getled
    ;;
  setled)
    $raccmd setled -l 1
    ;;
  disableled)
    $raccmd setled -l 0
    ;;
  help)
    $raccmd help
    ;;
  *)
    # Just run whatever was passed in
    $raccmd $command
    ;;
esac

