#!/system/bin/sh - 
#===============================================================================
#
#          FILE: playback.sh
# 
#         USAGE: ./playback.sh 
# 
#   DESCRIPTION: 把 ./recorder.sh 录制的内容输出成一个 send.sh 和 send.c 供回放
#                脚本唯一不好的地方：mindiff=0.1 此值并不代表所有操作的真实场景
#                详情请看脚本 TODO
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: lwq (28120), scue@vip.qq.com
#  ORGANIZATION: 
#       CREATED: Friday, December 05, 2014 12:30:37 CST CST
#      REVISION:  ---
#===============================================================================
BUSYBOX=/data/busybox
file=${1:-"record.txt"}                   # origin
#delete [ ' ' ], and replace '.' with ' '
$BUSYBOX sed 's/\[//g;s/ *//;s/\]//g;s/\./ /' $file >$file.format
#$BUSYBOX awk '{print $1}' $file.format | $BUSYBOX awk -F. '{print $1, $2}'
