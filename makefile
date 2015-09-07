# Makefile

libJNotificationCenter.jnilib: ~/Library/Developer/Xcode/DerivedData/JNotificationCenter-*/Build/Products/Debug/libJNotificationCenter.jnilib
	cp $^ $@

.PHONY: header
header:
	javah -force -o ./native/jnotificationcenter.h -cp src/ com.moomoohk.OSXUtils.JNotificationCenter
	sed -i "" 's/\<jni.h\>/\"jni.h\"/g' ./native/JNotificationCenter.h