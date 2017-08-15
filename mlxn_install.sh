#!/bin/sh
function fetch_rpm {
	# The script assume OFED is not and install the minimal installation required
        # which is libmlx5 & libibverbs
	CPU=$(lscpu | grep -oP 'Architecture:\s*\K.+')
	#wget http://linux.mellanox.com/public/repo/mlnx_ofed/latest/SRPMS/pmbuild.tar

        tar -vxf ./pmbuild.tar
	cd ./pmbuild
        cd $OS
        cd $VER
        #fetch the rpm from Mellanox web-site
	if [ $1 == "rpm" ]; then
		echo "rpm -ivh *.rpm"	
		rpm -ivh *.rpm
	else
		echo "dpkg -i *.deb"
		dpkg -i *.deb
	fi
}

if [ -f /etc/lsb-release ] || [ -f /etc/debian_version ]; then
	if [ $(dpkg -l | grep OFED | wc -l) -eq 0 ]; then
		if [ -f /etc/lsb-release ]; then
                    # For some versions of Debian/Ubuntu without lsb_release command
                    . /etc/lsb-release
                    OS=$DISTRIB_ID
		    OS=$(echo $OS | tr '[:upper:]' '[:lower:]')
                    VER=$DISTRIB_RELEASE
                elif [ -f /etc/debian_version ]; then
                    # Older Debian/Ubuntu/etc.
                    OS=ubuntu
                    VER=$(cat /etc/debian_version)
		    if [ $VER -eq 8 ]; then
			VER=14.04
		    elif [ $VER -eq 9 ]; then
			VER=16.10
		    else
			VER=17.04
		    fi
                fi
		fetch_rpm "deb" $OS $VER
	fi
elif [ -f /etc/redhat-release ]; then
	if [ $(rpm -qa | grep OFED | wc -l) -eq 0 ]; then
		if [ -f /etc/redhat-release ]; then
               		OS=$(cat /etc/redhat-release | cut -d ' ' -f 1)			
			if [ "$OS" == "Red" ] || [ "$OS" == "CentOs" ]; then
				OS=rhel
				VER=$(cat /etc/redhat-release | grep -oE '[0-9]+\.[0-9]+')				
			else	
				#Fedora 23,24 are mapped to rhel7.3	
				OS=rhel
				VER=$(cat /etc/redhat-release | grep -oE '[0-9][0-9]')
				echo $VER	
				if [ $VER -lt 14 ]; then 
					VER=6.0
				elif [ $VER -eq 19 ] || [ $VER -eq 20 ]; then 
					VER=7.0
				elif [ $VER -eq 21 ] || [ $VER -eq 22 ]; then 
					VER=7.1
				elif [ $VER -eq 22 ] || [ $VER -eq 23 ]; then
                                        VER=7.2
				elif [ $VER -gt 23 ]; then
                                        VER=7.3
				fi
			fi
		elif [ -f /etc/os-release ]; then
			# openSuse
	    		# freedesktop.org and systemd
	    		. /etc/os-release
			OS=sles
			VER=$VERSION_ID	
		elif type lsb_release >/dev/null 2>&1; then
	    		# linuxbase.org
	    		OS=$(lsb_release -si)
	    		VER=$(lsb_release -sr)
		else
	    		# Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
	    		OS=$(uname -s)
	    		VER=$(uname -r)
		fi
		fetch_rpm "rpm" $OS $VER
	fi
fi
echo "After installation"
