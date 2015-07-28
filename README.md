Ansible Mumble
==============

[http://mumble.info](http://mumble.info)

[https://github.com/layeh/gumble](https://github.com/layeh/gumble)

Requirements
------------

...

Role Variables
--------------

See defaults/main.yml

Dependencies
------------

Currently Debian only.

Example Playbook
----------------

    ---
    - hosts: webservers
      gather_facts: yes
      sudo: yes

      roles:
        - ansible-mumble

License
-------

MIT

Notes
-----

A couple of Sqlite examples to manipulate or view mumble data.

List mumble tables

	sqlite3 /var/lib/mumble-server/mumble-server.sqlite .tables

List mumble servers

    sudo sqlite3 -header /var/lib/mumble-server/mumble-server.sqlite "select * from servers"

List mumble users

	sudo sqlite3 -header /var/lib/mumble-server/mumble-server.sqlite "select * from users"

List mumble groups

	sudo sqlite3 -header /var/lib/mumble-server/mumble-server.sqlite "select * from groups"

Revoke self register

    sudo sqlite3 /var/lib/mumble-server/mumble-server.sqlite "update acl set revokepriv=524288, grantpriv=0 where group_name='all'"

List revoked and granted privileges

	sudo sqlite3 -header /var/lib/mumble-server/mumble-server.sqlite "select group_name, revokepriv, grantpriv from acl"

