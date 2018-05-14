#!/bin/sh
#Author mahongxin <hongxin_228@163.com>
set -x
. ../../../../utils/sys_info.sh
. ../../../../utils/sh-test-lib
cd -
# shellcheck disable=SC1091
#. ../../lib/sh-test-lib
#OUTPUT="$(pwd)/output"
#RESULT_FILE="${OUTPUT}/result.txt"
#export RESULT_FILE
INTERFACE="enahisic2i0"

#usage() {
#    echo "Usage: $0 [-s <true|false>] [-i <interface>]" 1>&2
#    exit 1
#}

#while getopts "s:i:" o; do
#  case "$o" in
 #   s) SKIP_INSTALL="${OPTARG}" ;;
 #   i) INTERFACE="${OPTARG}" ;;
  #  *) usage ;;
  #esac
#done

install() {
    pkgs="curl net-tools"
    install_deps "${pkgs}" "${SKIP_INSTALL}"
    print_info $? install-pkgs
}

run() {
    test_case="$1"
    test_case_id="$2"
    echo
    info_msg "Running ${test_case_id} test..."
    info_msg "Running ${test_case} test..."
    eval "${test_case}"
    check_return "${test_case_id}"
}

# Test run.
#create_out_dir "${OUTPUT}"

install

# Get default Route Gateway IP address of a given interface
GATEWAY=$(ip route list  | grep default | awk '{print $3}')

run "netstat -an" "print-network-statistics"
print_info $? netstat
run "ip addr" "list-all-network-interfaces"
print_info $? ip-addr
run "route" "print-routing-tables"
print_info $? route
run "ip link set lo up" "ip-link-loopback-up"
print_info $? ip-link
run "route" "route-dump-after-ip-link-loopback-up"
print_info $? route-dump
run "ip link set ${INTERFACE} up" "ip-link-interface-up"
run "ip link set ${INTERFACE} down" "ip-link-interface-down"
print_info $? ip-link
run "dhclient -v ${INTERFACE}" "Dynamic-Host-Configuration-Protocol-Client-dhclient-v"
print_info $? dhclient
run "route" "print-routing-tables-after-dhclient-request"
run "ping -c 5 ${GATEWAY}" "ping-gateway"
print_info $? ping-gateway
run "curl http://samplemedia.linaro.org/MPEG4/big_buck_bunny_720p_MPEG4_MP3_25fps_3300K.AVI -o curl_big_video.avi" "download-a-file"
print_info $? curl
#remove_deps "${pkgs}"
yum remove net-tools -y
print_info $? removse-pkgs
