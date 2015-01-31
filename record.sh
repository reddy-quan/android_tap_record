#!/system/bin/sh - 
#===============================================================================
#
#          FILE: recorder.sh
# 
#         USAGE: ./recorder.sh 
# 
#   DESCRIPTION: 录制 Android 屏幕事件，保存在 $file 文件上
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: lwq (28120), scue@vip.qq.com
#  ORGANIZATION: 
#       CREATED: Friday, December 05, 2014 12:24:26 CST CST
#      REVISION:  ---
#===============================================================================
BUSYBOX=/data/busybox
file=${1:-"record.txt"}

get_touch_device(){
    getevent -pl|$BUSYBOX sed -e ':a;N;$!ba;s/\n / /g'|\
        $BUSYBOX grep 'ABS_MT_TOUCH'|$BUSYBOX awk '{print $4}'|$BUSYBOX tr -d '\011\012\015'
}

touchdev=$(get_touch_device)
echo "touch device is [ $touchdev ]"

echo "--recorder start now, output file is [ $file ]"
trap "echo  '= recoder had stop ='" SIGINT
getevent -t $touchdev >$file
echo "--recorder start end, output file is [ $file ]"
