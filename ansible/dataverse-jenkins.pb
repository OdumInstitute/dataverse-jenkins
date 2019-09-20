- hosts: localhost
  roles:
    - role: jenkins
      become: true
