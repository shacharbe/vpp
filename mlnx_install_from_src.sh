#!/bin/sh
HOME=$(pwd)
function create_dir_tree {
	cd $HOME
	mkdir install
	mkdir build
	cd install
	mkdir lib
	mkdir include
	cd $HOME
}
function install_lib {
	echo "open tar file...."
	echo "$1"
	
	cd $HOME
	cd build
	mkdir $1
	cd $1
	mkdir include
	cd $HOME

        tar -xvzf $1.tar.gz
	rm -f $1.tar.gz
	echo "cd tar directory"	
	cd $1
	#./autogen.sh
	chmod +x ./configure	
	echo "configure"
	if [ -f /etc/redhat-release ]; then
               yum install libnl*
        elif [ -f /etc/lsb-release ] || [ -f /etc/debian_version ]; then
               apt install libnl*
        fi
	./configure --without-resolve-neigh --prefix=$HOME/install --with-perl-installdir=$HOME/install	LDFLAGS='-L$HOME/install/lib -Wl,-rpath,$HOME/install/lib ' CFLAGS='-I$HOME/install/include -I$HOME/build/$1/include ' CPPFLAGS='-I$HOME/install/include -I$HOME/build/$1/include ' CXXFLAGS='-I$HOME/install/include -I$HOME/build/$1/include '
	echo "make && make install"
	make -j 8  && make -j 8 install	
	cd $HOME
}

function install_libmlx5_libibverbs {
	wget -nd -r -l1 -A libibverbs-*.tar.gz http://linux.mellanox.com/public/repo/mlnx_ofed/latest/SRPMS/
	LIB=$(ls *.tar.gz | grep libibverbs | cut -d"." -f1)
	echo $LIB
	install_lib $LIB

	wget -nd -r -l1 -A libmlx5-*.tar.gz http://linux.mellanox.com/public/repo/mlnx_ofed/latest/SRPMS/
	LIB=$(ls *.tar.gz | grep libmlx5 | cut -d"." -f1)
	echo $LIB
	install_lib $LIB
}

# The script assume OFED is not and install the minimal installation required
# which is libmlx5 & libibverbs
if [ -f /etc/lsb-release ] || [ -f /etc/debian_version ]; then
	if [ $(dpkg -l | grep OFED | wc -l) -eq 0 ]; then
		echo "Ubuntu is installed"
		create_dir_tree	
		install_libmlx5_libibverbs	
	fi
elif [ -f /etc/redhat-release ]; then
	if [ $(rpm -qa | grep OFED | wc -l) -eq 0 ]; then
		echo "RHEL is installed"
		create_dir_tree
		install_libmlx5_libibverbs
	fi
fi
echo "After installation"
