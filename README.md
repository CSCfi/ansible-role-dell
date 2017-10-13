[![Build Status](https://travis-ci.org/CSCfi/ansible-role-dell.svg)](https://travis-ci.org/CSCfi/ansible-role-dell)
ansible-role-dell
=========

Installs Dell DSU yum repo and related softwares for managing a Dell server 

http://linux.dell.com/repo/hardware/dsu/

Requirements
------------

 - ansible -m setup and system_vendor should say "Dell Inc."

Role Variables
--------------

install_dell_dsu: True

dell_disable_vil7: True

disable_vil7 - This means OMSA won't load the dsm_sm_psrvil library - this disables NVMe detection by OMSA but it also makes all the omreport commands work on CentOS7.
More details in the e-mails in linux-poweredge@lists.us.dell.com

Dependencies
------------


Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: ansible-role-dell }

License
-------

MIT

Author Information
------------------

Johan Guldmyr
