//
//  DMAppDelegate.m
//  aGHC
//
//  Created by Daniel Miedema on 3/8/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMAppDelegate.h"
#import "TestFlight.h"

@implementation DMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
#if TESTING
    /* 
    // pre iOS 6 method
    CFUUIDRef UUID = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef UIDstring = CFUUIDCreateString(kCFAllocatorDefault, UUID);
    CFRelease(UUID);
    NSString *string = [NSString string];
    string = (__bridge_transfer NSString *)UIDstring;
     */
    NSString *id;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id = [defaults objectForKey:kUUID];
    if (id == nil) {
        id = [[NSUUID UUID] UUIDString];
        [defaults setObject:id forKey:kUUID];
        [defaults synchronize];
    }
    [TestFlight setDeviceIdentifier:id];
    NSLog(@"Generated UUID: %@", id);
#endif
    // TestFlight Take Off!
    [TestFlight takeOff:@"e7a2d4c8-b326-403d-9df2-c5c0ad156419"];
    
    // TestFlight Logger
    [DDLog addLogger:[TestFlightLogger sharedInstance]];
    
    // Override point for customization after application launch.
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] stringForKey:kAccessToken];
    if (accessToken) {
        NSLog(@"Account_Token: %@", [[NSUserDefaults standardUserDefaults] stringForKey:kAccessToken]);
    } else {
        NSLog(@"No Access Token Found, will need to log in");
    }

    //
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
