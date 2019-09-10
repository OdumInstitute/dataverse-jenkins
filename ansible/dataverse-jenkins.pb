- hosts: jenkins
  roles:
    - role: geerlingguy.jenkins
      become: yes
