#!/bin/sh
function fetch_rpm {
        # The script assume OFED is not and install the minimal installation required
        # which is libmlx5 & libibverbs
        #fetch the rpm from Mellanox web-site
        url=http://linux.mellanox.com/public/repo/mlnx_ofed/latest/$OS$VER/$CPU/
        echo $url
        libmlx5_rpm="libmlx5-*""$CPU".$1
        libibverbs_rpm="libibverbs*""$CPU".$1
	libmlx5_dbg_rpm="libmlx5-1-dbg*""$CPU".$1
        libmlx5_devel_rpm="libmlx5-dev*""$CPU".$1
        libibverbs_devel_rpm="libibverbs-dev*""$CPU".$1
        libibverbs_util_rpm="libibverbs-util*""$CPU".$1
        libibverbs_dbg_rpm="libibverbs1-dbg_*""$CPU".$1
        echo $libmlx5_rpm
        echo $libibverbs_rpm
        echo $libmlx5_devel_rpm
        echo $libibverbs_devel_rpm
        echo $libibverbs_util_rpm
        wget -nd -r -l1 -A $libmlx5_rpm -R $libmlx5_devel_rpm -R $libmlx5_dbg_rpm $url
        wget -nd -r -l1 -A $libibverbs_rpm -R $libibverbs_devel_rpm -R $libibverbs_util_rpm -R $libibverbs_dbg_rpm $url 
}
declare -a array_os=("ubuntu" "rhel")
declare -a array_ubuntu_ver=("14.04" "16.04" "16.10" "17.04")
declare -a array_rhel_ver=("6.2" "6.3" "6.4" "6.5" "6.6" "6.7" "6.8" "6.9" "7.0" "7.1" "7.2" "7.3")
arrayoslength=${#array_os[@]}
arrayubverlength=${#array_ubuntu_ver[@]}
arrayrhelverlength=${#array_rhel_ver[@]}
CPU=amd64
mkdir pmbuild
cd pmbuild
mkdir ${array_os[0]}
cd ${array_os[0]}
for (( j=1; j<${arrayubverlength}+1; j++ ));
do
    OS=${array_os[0]}
    VER=${array_ubuntu_ver[$j-1]}	
    mkdir ${array_ubuntu_ver[$j-1]}
    cd ${array_ubuntu_ver[$j-1]}
    fetch_rpm "deb" 
    cd ../ 
done
cd ../
mkdir ${array_os[1]}
cd ${array_os[1]}
CPU=x86_64
for (( j=1; j<${arrayrhelverlength}+1; j++ ));
do
    OS=${array_os[1]}
    VER=${array_rhel_ver[$j-1]}
    mkdir ${array_rhel_ver[$j-1]}
    cd ${array_rhel_ver[$j-1]}
    fetch_rpm "rpm"
    cd ../
done
cd ../../
tar -cvf pmbuild.tar pmbuild 
















