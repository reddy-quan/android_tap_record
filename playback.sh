#!/system/bin/sh
#===============================================================================
#
#          FILE: playback.sh
# 
#         USAGE: ./playback.sh
#				 Then prepare you phone ready, and run: ./play.sh
# 
#   DESCRIPTION: 回放
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: lwq (28120), scue@vip.qq.com
#				 Red Devil 20150131 create for run on android
#  ORGANIZATION: 
#       CREATED: 
#      REVISION:  ---
#===============================================================================
#Need busybox to provide awk/sed etc
#BUSYBOX=/data/busybox.miui
#BUSYBOX=/data/busybox
BUSYBOX=/mnt/sdcard/busybox
file=${1:-"m.txt"}

get_touch_device(){
    getevent -pl 2>/dev/null|$BUSYBOX sed -e ':a;N;$!ba;s/\n / /g'|\
        $BUSYBOX grep 'ABS_MT_TOUCH'|$BUSYBOX awk '{print $4}'|$BUSYBOX tr -d '\011\012\015'
}

touchdev=$(get_touch_device)

cat $file | ./busybox dos2unix > $file.unix
#delete [ ' ' ], and replace '.' with ' '
$BUSYBOX sed 's/\[//g;s/ *//;s/\]//g;s/\./ /' $file.unix >$file.format

cat $file.format | $BUSYBOX awk -v dev=$touchdev 'BEGIN{last_t=0}
NR==1{OFMT="%.6f";
last_t=$1"."$2;
print "#!/system/bin/sh";
cmd="let num=0x"$3";let num2=0x"$4";let num3=0x"$5";echo sendevent "dev" $num $num2 $num3";
system(cmd);
}
NR>1{OFMT="%.6f";now_t=$1"."$2;
delay=now_t-last_t;
if(delay>0)
print "sleep",delay;
last_t=now_t;
cmd="let num=0x"$3";let num2=0x"$4";let num3=0x"$5";echo sendevent "dev" $num $num2 $num3";
system(cmd);
}' >play.sh
#| $BUSYBOX tee play.sh

#OK, NO Need to chmod
#chmod 777 play.sh
rm $file.format $file.unix 2>/dev/null
#echo "OK, now you can run ./play.sh to play back touch event"

echo "OK, REPLAYING..."
./play.sh

rm play.sh
