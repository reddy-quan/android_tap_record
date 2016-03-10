#Android触屏事件录制与回放

原理：
先使用getevent将驱动上报的事件保存起来，并保存成一个文件。
回放时调用sendevent将保存的事件再原封不动的播放出来。

由于使用sendevent效率比较低，所以我在toolbox的基础上扩充了一个applet叫playback，它可以直接读取录制的事件的文本，并回放。

Red Devil port for run on Android:
#usage:

1. ./record.sh 
（这种方法发现有时候抓不到结果，建议直接getevent -t /dev/input/eventx将输出结果保存起来，
替换其中的\r\n为\n）

2. ./playback.sh > play.sh && chmod 777 play.sh && ./play.sh
