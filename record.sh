#!/system/bin/sh - 
#===============================================================================
#          FILE: record.sh
#         USAGE: ./record.sh 
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
file=${1:-"m.txt"}

get_touch_device(){
    getevent -pl 2>/dev/null|$BUSYBOX sed -e ':a;N;$!ba;s/\n / /g'|\
        $BUSYBOX grep 'ABS_MT_TOUCH'|$BUSYBOX awk '{print $4}'|$BUSYBOX tr -d '\011\012\015'
}

touchdev=$(get_touch_device)
echo "touch device is [ $touchdev ]"

echo "--recorder start now, output file is [ $file ]"
echo "pid is: $$"

trap "echo  '= recoder had stop ='" SIGINT
# 用重定向到文件的方法有缺陷，时候半天不出来
# 执行getevent -t将执行结果保存起来最安全
#getevent -t $touchdev >$file
getevent -t $touchdev

echo "--recorder start end, output file is [ $file ]"
