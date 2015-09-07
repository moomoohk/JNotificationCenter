# JNotificationCenter
OSX Notification Center API for Java

The Objective-C bits of the code are located in the `native` folder and they contain all the direct communication with Notification Center.

The Java code located in the `src` folder forms the wrapper with JNI.

To make it all work you need to add `JNotificationCenter.jar` to your build path, place `JNotificationCenter.jnilib` in your project's root and import `com.moomoohk.JNotificationCenter.JNotificationCenter`.

![](https://cloud.githubusercontent.com/assets/2220203/9722724/516e63e4-55bb-11e5-9338-ca88dbb05564.png "Screenshot!")

I utilized [terminal-notifier](https://github.com/julienXX/terminal-notifier).
