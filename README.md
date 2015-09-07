# JNotificationCenter
OSX Notification Center API for Java

The Objective-C bits of the code are located in the `native` folder and they contain all the direct communication with Notification Center.

The Java code located in the `src` folder forms the wrapper with JNI.

To make it all work you need to add `JNotificationCenter.jar` to your buildpath and place `JNotificationCenter.jnilib` in your project's root.

![](https://cloud.githubusercontent.com/assets/2220203/9722281/ef1274cc-55b2-11e5-89d3-af998da34def.png "Screenshot!")

I utilized [terminal-notifier](https://github.com/julienXX/terminal-notifier).
