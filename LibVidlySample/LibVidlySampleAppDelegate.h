//
//  LibVidlySampleAppDelegate.h
//  LibVidlySample
//
//  Created by Tamas Zsar on 2011.08.21..
//  Copyright 2011 encoding.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Vidly.h"

@interface LibVidlySampleAppDelegate : NSObject <UIApplicationDelegate, VidlyDelegate> 

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end
