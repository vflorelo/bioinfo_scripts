#!/bin/bash
sshfs -o uid=1002 -o gid=1002 -o allow_other,default_permissions vflorelo@www.atglabs.org:/usr/local/bioinformatics/misc/vflorelo/Books     /home/vflorelo/Books
sshfs -o uid=1002 -o gid=1002 -o allow_other,default_permissions vflorelo@www.atglabs.org:/usr/local/bioinformatics/misc/vflorelo/Documents /home/vflorelo/Documents
sshfs -o uid=1002 -o gid=1002 -o allow_other,default_permissions vflorelo@www.atglabs.org:/usr/local/bioinformatics/misc/vflorelo/Downloads /home/vflorelo/Downloads
sshfs -o uid=1002 -o gid=1002 -o allow_other,default_permissions vflorelo@www.atglabs.org:/usr/local/bioinformatics/misc/vflorelo/git       /home/vflorelo/git
sshfs -o uid=1002 -o gid=1002 -o allow_other,default_permissions vflorelo@www.atglabs.org:/usr/local/bioinformatics/misc/vflorelo/Music     /home/vflorelo/Music
sshfs -o uid=1002 -o gid=1002 -o allow_other,default_permissions vflorelo@www.atglabs.org:/usr/local/bioinformatics/misc/vflorelo/other     /home/vflorelo/other
sshfs -o uid=1002 -o gid=1002 -o allow_other,default_permissions vflorelo@www.atglabs.org:/usr/local/bioinformatics/misc/vflorelo/Pictures  /home/vflorelo/Pictures
