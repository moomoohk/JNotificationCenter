# Makefile

libJNotificationCenter.jnilib: ./native/DerivedData/JNotificationCenter/Build/Products/Debug/libJNotificationCenter.jnilib
	cp $^ $@

.PHONY: header
header:
	javah -force -o ./native/jnotificationcenter.h -cp src/ com.moomoohk.JNotificationCenter.JNotificationCenter
	sed -i "" 's/\<jni.h\>/\"jni.h\"/g' ./native/JNotificationCenter.h