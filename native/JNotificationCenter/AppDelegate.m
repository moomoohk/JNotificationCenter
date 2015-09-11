#import "AppDelegate.h"
#import <ScriptingBridge/ScriptingBridge.h>
#import <objc/runtime.h>
#import "JavaNativeFoundation/JavaNativeFoundation.h"

#include "External Headers/SimpleNotification.h"
#include "External Headers/URLNotification.h"

NSString * const TerminalNotifierBundleID = @"nl.superalloy.oss.terminal-notifier";
NSString * const NotificationCenterUIBundleID = @"com.apple.notificationcenterui";

// Set OS Params
#define NSAppKitVersionNumber10_8 1187
#define NSAppKitVersionNumber10_9 1265

#define contains(str1, str2) ([str1 rangeOfString: str2 ].location != NSNotFound)

NSString *_fakeBundleIdentifier = nil;

@implementation NSBundle (FakeBundleIdentifier)

// Overriding bundleIdentifier works, but overriding NSUserNotificationAlertStyle does not work.

- (NSString *)__bundleIdentifier;
{
  if (self == [NSBundle mainBundle]) {
    return _fakeBundleIdentifier ? _fakeBundleIdentifier : TerminalNotifierBundleID;
  } else {
    return [self __bundleIdentifier];
  }
}

@end

static BOOL
InstallFakeBundleIdentifierHook()
{
  Class class = objc_getClass("NSBundle");
  if (class) {
    method_exchangeImplementations(class_getInstanceMethod(class, @selector(bundleIdentifier)),
                                   class_getInstanceMethod(class, @selector(__bundleIdentifier)));
    return YES;
  }
  return NO;
}

static BOOL
isMavericks()
{
  if (floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_8) {
    /* On a 10.8 - 10.8.x system */
    return NO;
  } else {
    /* 10.9 or later system */
    return YES;
  }
}

@implementation NSUserDefaults (SubscriptAndUnescape)
- (id)objectForKeyedSubscript:(id)key;
{
  id obj = [self objectForKey:key];
  if ([obj isKindOfClass:[NSString class]] && [(NSString *)obj hasPrefix:@"\\"]) {
    obj = [(NSString *)obj substringFromIndex:1];
  }
  return obj;
}
@end


@implementation AppDelegate

+(void)initializeUserDefaults
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

  // initialize the dictionary with default values depending on OS level
  NSDictionary *appDefaults;

  if (isMavericks()) {
    //10.9
    appDefaults = @{@"sender": @"com.apple.Terminal"};
  } else {
    //10.8
    appDefaults = @{@"": @"message"};
  }

  // and set them appropriately
  [defaults registerDefaults:appDefaults];
}

- (NSImage*)getImageFromURL:(NSString *) url;
{
  NSURL *imageURL = [NSURL URLWithString:url];
  if([[imageURL scheme] length] == 0){
    // Prefix 'file://' if no scheme
    imageURL = [NSURL fileURLWithPath:url];
  }
  return [[NSImage alloc] initWithContentsOfURL:imageURL];
}

/**
 * Decode fragment identifier
 *
 * @see http://tools.ietf.org/html/rfc3986#section-2.1
 * @see http://en.wikipedia.org/wiki/URI_scheme
 */
- (NSString*)decodeFragmentInURL:(NSString *) encodedURL fragment:(NSString *) framgent
{
    NSString *beforeStr = [@"%23" stringByAppendingString:framgent];
    NSString *afterStr = [@"#" stringByAppendingString:framgent];
    NSString *decodedURL = [encodedURL stringByReplacingOccurrencesOfString:beforeStr withString:afterStr];
    return decodedURL;
}

- (void)deliverNotificationWithTitle:(NSString *)title
                             subtitle:(NSString *)subtitle
                             message:(NSString *)message
                             options:(NSDictionary *)options
                               sound:(NSString *)sound;
{
    if (options[@"sender"]) {
        @autoreleasepool {
            if (InstallFakeBundleIdentifierHook()) {
                _fakeBundleIdentifier = options[@"sender"];
            }
        }
    }
  // First remove earlier notification with the same group ID.
  if (options[@"groupID"]) [self removeNotificationWithGroupID:options[@"groupID"]];

  NSUserNotification *userNotification = [NSUserNotification new];
  userNotification.title = title;
  userNotification.subtitle = subtitle;
  userNotification.informativeText = message;
  userNotification.userInfo = options;

  if(isMavericks()){
    // Mavericks options
    if(options[@"appIcon"]){
      // replacement app icon
      [userNotification setValue:[self getImageFromURL:options[@"appIcon"]] forKey:@"_identityImage"];
      [userNotification setValue:@(false) forKey:@"_identityImageHasBorder"];
    }
    if(options[@"contentImage"]){
      // content image
      userNotification.contentImage = [self getImageFromURL:options[@"contentImage"]];
    }
  }

  if (sound != nil) {
    userNotification.soundName = [sound isEqualToString: @"default"] ? NSUserNotificationDefaultSoundName : sound ;
  }

  NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
  center.delegate = self;
  [center scheduleNotification:userNotification];
}

- (void)removeNotificationWithGroupID:(NSString *)groupID;
{
  NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
  for (NSUserNotification *userNotification in center.deliveredNotifications) {
    if ([@"ALL" isEqualToString:groupID] || [userNotification.userInfo[@"groupID"] isEqualToString:groupID]) {
      NSString *deliveredAt = [userNotification.actualDeliveryDate description];
      printf("* Removing previously sent notification, which was sent on: %s\n", [deliveredAt UTF8String]);
      [center removeDeliveredNotification:userNotification];
    }
  }
}

- (void)listNotificationWithGroupID:(NSString *)listGroupID;
{
  NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];

  NSMutableArray *lines = [NSMutableArray array];
  for (NSUserNotification *userNotification in center.deliveredNotifications) {
    NSString *deliveredgroupID = userNotification.userInfo[@"groupID"];
    NSString *title            = userNotification.title;
    NSString *subtitle         = userNotification.subtitle;
    NSString *message          = userNotification.informativeText;
    NSString *deliveredAt      = [userNotification.actualDeliveryDate description];
    if ([@"ALL" isEqualToString:listGroupID] || [deliveredgroupID isEqualToString:listGroupID]) {
      [lines addObject:[NSString stringWithFormat:@"%@\t%@\t%@\t%@\t%@", deliveredgroupID, title, subtitle, message, deliveredAt]];
    }
  }

  if (lines.count > 0) {
    printf("GroupID\tTitle\tSubtitle\tMessage\tDelivered At\n");
    for (NSString *line in lines) {
      printf("%s\n", [line UTF8String]);
    }
  }
}


- (void)userActivatedNotification:(NSUserNotification *)userNotification;
{
    printf("activated\n");
  [[NSUserNotificationCenter defaultUserNotificationCenter] removeDeliveredNotification:userNotification];

  NSString *groupID  = userNotification.userInfo[@"groupID"];
  NSString *bundleID = userNotification.userInfo[@"bundleID"];
  NSString *command  = userNotification.userInfo[@"command"];
  NSString *open     = userNotification.userInfo[@"open"];

  NSLog(@"User activated notification:");
  NSLog(@" group ID: %@", groupID);
  NSLog(@"    title: %@", userNotification.title);
  NSLog(@" subtitle: %@", userNotification.subtitle);
  NSLog(@"  message: %@", userNotification.informativeText);
  NSLog(@"bundle ID: %@", bundleID);
  NSLog(@"  command: %@", command);
  NSLog(@"     open: %@", open);

    printf("url %s\n", [[[NSURL URLWithString:open] fragment] UTF8String]);
    
  BOOL success = YES;
  if (bundleID) success &= [self activateAppWithBundleID:bundleID];
  if (command)  success &= [self executeShellCommand:command];
  if (open)     success &= [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:open]];

    printf("%d", success);
    
  exit(success ? 0 : 1);
}

- (BOOL)activateAppWithBundleID:(NSString *)bundleID;
{
  id app = [SBApplication applicationWithBundleIdentifier:bundleID];
  if (app) {
    [app activate];
    return YES;

  } else {
    NSLog(@"Unable to find an application with the specified bundle indentifier.");
    return NO;
  }
}

- (BOOL)executeShellCommand:(NSString *)command;
{
  NSPipe *pipe = [NSPipe pipe];
  NSFileHandle *fileHandle = [pipe fileHandleForReading];

  NSTask *task = [NSTask new];
  task.launchPath = @"/bin/sh";
  task.arguments = @[@"-c", command];
  task.standardOutput = pipe;
  task.standardError = pipe;
  [task launch];

  NSData *data = nil;
  NSMutableData *accumulatedData = [NSMutableData data];
  while ((data = [fileHandle availableData]) && [data length]) {
    [accumulatedData appendData:data];
  }

  [task waitUntilExit];
  NSLog(@"command output:\n%@", [[NSString alloc] initWithData:accumulatedData encoding:NSUTF8StringEncoding]);
  return [task terminationStatus] == 0;
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center
     shouldPresentNotification:(NSUserNotification *)userNotification;
{
  return YES;
}

// Once the notification is delivered we can exit.
- (void)userNotificationCenter:(NSUserNotificationCenter *)center
        didDeliverNotification:(NSUserNotification *)userNotification;
{
  exit(0);
}

@end

JNIEXPORT void JNICALL Java_com_moomoohk_JNotificationCenter_notifications_SimpleNotification_show(JNIEnv* env, jobject jthis, jstring jtitle, jstring jmessage, jstring jsubtitle, jstring jsender, jstring jsound) {
    JNF_COCOA_ENTER(env);
    AppDelegate* appDelegate = [AppDelegate new];
    NSString* title = JNFJavaToNSString(env, jtitle);
    NSString* message = JNFJavaToNSString(env, jmessage);
    NSString* subtitle = JNFJavaToNSString(env, jsubtitle);
    NSString* sender = JNFJavaToNSString(env, jsender);
    NSString* sound = JNFJavaToNSString(env, jsound);
    
    [appDelegate deliverNotificationWithTitle:title
                                     subtitle:subtitle
                                      message:message
                                      options:@{@"sender": sender}
                                        sound:sound];
    JNF_COCOA_EXIT(env);
}

JNIEXPORT void JNICALL Java_com_moomoohk_JNotificationCenter_notifications_URLNotification_show(JNIEnv* env, jobject jthis, jstring jtitle, jstring jmessage, jstring jsubtitle, jstring jsender, jstring jsound, jstring jurl) {
    JNF_COCOA_ENTER(env);
    AppDelegate* appDelegate = [AppDelegate new];
    NSString* title = JNFJavaToNSString(env, jtitle);
    NSString* message = JNFJavaToNSString(env, jmessage);
    NSString* subtitle = JNFJavaToNSString(env, jsubtitle);
    NSString* sender = JNFJavaToNSString(env, jsender);
    NSString* sound = JNFJavaToNSString(env, jsound);
    NSString* url = JNFJavaToNSString(env, jurl);
    
    NSString *encodedURL = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *urlObj = [NSURL URLWithString:url];
    NSString *fragment = [urlObj fragment];
    
    NSString* openParam = fragment ? [appDelegate decodeFragmentInURL:encodedURL fragment:fragment] : encodedURL;
    
    [appDelegate deliverNotificationWithTitle:title
                                     subtitle:subtitle
                                      message:message
                                      options:@{
                                                @"sender": sender,
                                                @"open": openParam
                                                }
                                        sound:sound];
    JNF_COCOA_EXIT(env);
    printf("Done\n");
}
