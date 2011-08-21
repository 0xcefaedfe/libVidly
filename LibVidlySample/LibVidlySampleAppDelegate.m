//
//  LibVidlySampleAppDelegate.m
//  LibVidlySample
//
//  Created by Tamas Zsar on 2011.08.21..
//  Copyright 2011 encoding.com. All rights reserved.
//

#import "LibVidlySampleAppDelegate.h"

// change these to test the library
static NSString *userID = nil;
static NSString *userKey = nil;
static NSString *sourceURL = nil;

@implementation LibVidlySampleAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSAssert(userID != nil, @"enter a valid userID");
    NSAssert(userKey != nil, @"enter a userKey userID");    
    NSAssert(sourceURL != nil, @"enter a sourceURL");    
    
    // instantiate the Vidly class with a valid userID, userKey and a delegate
    Vidly *vidly = [[Vidly alloc] initWithUserID:userID userKey:userKey andDelegate:self];
    // call one of the method, check Vidly.h for details
    [vidly addMedia:[NSArray arrayWithObjects:sourceURL, nil]];
    [vidly release];

    [self.window makeKeyAndVisible];    
    return YES;
}

#pragma mark -
#pragma mark VidlyDelegate

- (void)vidly:(Vidly *)vidly didFailedWithError:(NSError *)error {
    NSLog(@"Vid.ly failed with error: %@", error);  
}

- (void)vidly:(Vidly *)vidly didReceiveResponse:(NSDictionary *)response {
    NSLog(@"Vid.ly finished with response: %@", response);
}

- (void)dealloc {
    [_window release];
    [super dealloc];
}

@end
