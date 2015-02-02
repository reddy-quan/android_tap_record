@echo off
echo 将手机插入电脑，确保adb口正常
echo 录制完成后，不要关此窗口，将当前窗口输入全部拷贝出来，
echo 并另存为m.txt
echo ------------准备好了吗？------------
pause
cls && adb shell getevent -t /dev/input/event0


