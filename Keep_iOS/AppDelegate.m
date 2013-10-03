//
//  AppDelegate.m
//  Keep
//
//  Created by Sean Patno on 8/5/13.
//  Copyright (c) 2013 Sean Patno. All rights reserved.
//

#import "AppDelegate.h"

#import "Flurry.h"
#import "DHFormUtilities.h"
#import "DataManager.h"
#import "UIImage+iPhone5.h"
#import "ServerListViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    [Flurry startSession:@"NCPK87RPVM67GX25M9PX"];
    [Flurry setCrashReportingEnabled:YES];


    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSObject * object = [defaults objectForKey:@"application_UUID"];
    if(object != nil){
        //object is there
        NSLog(@"UUID already set: %@", object);
    }
    else
    {
        NSString *uuid = [[NSProcessInfo processInfo] globallyUniqueString];
        [defaults setObject:uuid forKey:@"application_UUID"];

        NSLog(@"UUID not found, setting: %@", uuid);
    }

    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        // Load resources for iOS 6.1 or earlier
        UIUserInterfaceIdiom idiom = [[UIDevice currentDevice] userInterfaceIdiom];
        if (idiom == UIUserInterfaceIdiomPad) {
            [self customizeiPadTheme];
        } else {
            [self customizeiPhoneTheme];
        }
    } else {
        // Load resources for iOS 7 or later
        [self set7Theme];
    }

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.

    ServerListViewController * serverList = [[ServerListViewController alloc] initWithStyle:UITableViewStylePlain];

    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:serverList];
    self.viewController = nav;

    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[DataManager instance] saveDataToFilesystem];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [DHFormUtilities sendStoredForms:nil];

    for( KeepServer * server in [DataManager instance].servers ) {
        [DHFormUtilities sendStoredForms:server];
    }
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void) set7Theme
{
    [[UINavigationBar appearance] setTintColor:[UIColor blueColor]];
}

-(void)customizeiPhoneTheme
{

    [[UIApplication sharedApplication]
     setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];

    UIImage *navBarImage = [[UIImage tallImageNamed:@"menubar.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 15, 5, 15)];

    [[UINavigationBar appearance] setBackgroundImage:navBarImage forBarMetrics:UIBarMetricsDefault];


    UIImage *barButton = [[UIImage tallImageNamed:@"menubar-button.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 4)];

    [[UIBarButtonItem appearance] setBackgroundImage:barButton forState:UIControlStateNormal
                                          barMetrics:UIBarMetricsDefault];

    UIImage *backButton = [[UIImage tallImageNamed:@"back.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 4)];

    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButton forState:UIControlStateNormal
                                                    barMetrics:UIBarMetricsDefault];


}

-(void)customizeiPadTheme
{
    UIImage *navBarImage = [UIImage tallImageNamed:@"ipad-menubar-right.png"];

    [[UINavigationBar appearance] setBackgroundImage:navBarImage forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0],
      UITextAttributeTextColor,
      [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8],
      UITextAttributeTextShadowColor,
      [NSValue valueWithUIOffset:UIOffsetMake(0, -1)],
      UITextAttributeTextShadowOffset,
      nil]];

    UIImage *barItemImage = [[UIImage tallImageNamed:@"ipad-menubar-button.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    [[UIBarButtonItem appearance] setBackgroundImage:barItemImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    
}

@end
