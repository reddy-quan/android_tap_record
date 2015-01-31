#Android触屏事件录制与回放

Red Devil port for run on Android:
#usage:

1. ./record.sh 
（这种方法发现有时候抓不到结果，建议直接getevent -t /dev/input/eventx将输出结果保存起来，
替换其中的\r\n为\n）

2. ./playback.sh > play.sh && chmod 777 play.sh && ./play.sh
