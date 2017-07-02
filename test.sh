#!/usr/bin/env bash

CURRENT_DIR=${PWD}
TMP_DIR=/tmp/ansible-test
mkdir -p ${TMP_DIR} 2> /dev/null

# Create hosts inventory
cat << EOF > ${TMP_DIR}/hosts
[webservers]
localhost ansible_connection=local
EOF

# Create group_vars for the web servers
mkdir -p ${TMP_DIR}/group_vars 2> /dev/null
cat << EOF > ${TMP_DIR}/group_vars/webservers
mumble_admin_password: "test-admin"
mumble_db_path: /var/lib/mumble-server/mumble-server.sqlite
mumble_log_path: /var/log/mumble-server/mumble-server.log
mumble_port: 64746
mumble_server_password: "test"
mumble_max_bandwidth: 72000
mumble_max_users: 10
mumble_user_name: "mumble-server"
mumble_welcome_text: "<br />Welcome to this server running <b>Murmur</b>.<br />"
mumble_reset: true
mumble_revoke_self_register: true

mumble_channels:
    - name: "Ingress"
      id: 10
      parent_id: 0
      server_id: 1
    - name: "The Lounge"
      id: 12
      parent_id: 0
      server_id: 1
    - name: "Enlightened"
      id: 14
      parent_id: 10
      server_id: 1

EOF

# Create Ansible config
cat << EOF > ${TMP_DIR}/ansible.cfg
[defaults]
roles_path = ${CURRENT_DIR}/../
host_key_checking = False
EOF

# Create playbook.yml
cat << EOF > ${TMP_DIR}/playbook.yml
---

- hosts: webservers
  gather_facts: yes
  become: yes

  roles:
    - ansible-mumble
EOF

export ANSIBLE_CONFIG=${TMP_DIR}/ansible.cfg

# Syntax check
ansible-playbook ${TMP_DIR}/playbook.yml -i ${TMP_DIR}/hosts --syntax-check

# First run
ansible-playbook ${TMP_DIR}/playbook.yml -i ${TMP_DIR}/hosts

export ANSIBLE_CONFIG=/tmp/ansible-test/ansible.cfg
ansible-playbook /tmp/ansible-test/playbook.yml -i /tmp/ansible-test/hosts | grep -q 'changed=8.*failed=0'

# Idempotence test
ansible-playbook ${TMP_DIR}/playbook.yml -i ${TMP_DIR}/hosts | grep -q 'changed=8.*failed=0' \
  && (echo 'Idempotence test: pass' && exit 0) \
  || (echo 'Idempotence test: fail' && exit 1)

# netstat -tulpn | grep 64746
