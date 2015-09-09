# Makefile

native_files = SimpleNotification
output_dir = ./native/JNotificationCenter/External\ Headers/

.PHONY: headers lib

lib: libJNotificationCenter.jnilib

libJNotificationCenter.jnilib: ./native/DerivedData/JNotificationCenter/Build/Products/Debug/libJNotificationCenter.jnilib
	xcodebuild -project native/JNotificationCenter.xcodeproj -scheme JNotificationCenter
	cp -f $^ $@

headers:
	$(foreach native_file, $(native_files), \
		javah -force -o $(output_dir)$(native_file).h -cp src/ com.moomoohk.JNotificationCenter.notifications.$(native_file) ; \
		sed -i "" "s/\<jni.h\>/\"jni.h\"/g" $(output_dir)$(native_file).h ; \
	)