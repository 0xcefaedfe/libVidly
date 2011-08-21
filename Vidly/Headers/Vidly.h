//
//  Vidly.h
//  libVidly
//
//  Created by Tamas Zsar on 2011.08.20..
//  Copyright 2011 encoding.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    VidlyActionAddMedia,
    VidlyActionDeleteMedia,
    VidlyActionGetStatus
} VidlyAction;

typedef enum {
    VidlyErrorInvalidParameterDictionary = -100,
    VidlyErrorConnectionFailed = -101
} VidlyError;

typedef enum {
    VidlyConnectionStatusReady,
    VidlyConnectionStatusRunning,
    VidlyConnectionStatusFailed
} VidlyConnectionStatus;

@class Vidly;

@protocol VidlyDelegate <NSObject>
- (void)vidly:(Vidly*)vidly didReceiveResponse:(NSDictionary*)response;
- (void)vidly:(Vidly*)vidly didFailedWithError:(NSError*)error;
@end

@interface Vidly : NSObject {
    NSString *_userID;      // ID of the user who perfoms the action. This ID may be seen in backend.
    NSString *_userKey;     // user key of the user who perfoms this action. This key may be seen in backend.
    NSString *_notifyURL;   // URL or email for response to be sent to.
    
    id<VidlyDelegate> _delegate;    // the delegate that should be notified when an action is finished or failed
    
    // connection
    VidlyConnectionStatus _status;
    NSURLConnection *_urlConnection;
    NSMutableData *_data;
}

// properties
@property (nonatomic, retain) NSString *userID;
@property (nonatomic, retain) NSString *userKey;
@property (nonatomic, retain) NSString *notifyURL;
@property (nonatomic, assign) id<VidlyDelegate> delegate;
@property (readonly) VidlyConnectionStatus status;

// methods
// initialize Vidly, visit http://api.vid.ly to register an account and receive a userID and userKey
- (id)initWithUserID:(NSString*)userID userKey:(NSString*)userKey andDelegate:(id<VidlyDelegate>)delegate;
// call the addMedia action with an array of source URLs. response dictionary will contain the mediaShortLinks for each URL
- (void)addMedia:(NSArray*)sourceURLs;
// call deleteMedia action with an array of mediaShortLinks
- (void)deleteMedia:(NSArray*)mediaShortLinks;
// call getStatus with an array of mediaShortLinks
- (void)getStatus:(NSArray*)mediaShortLinks;
// if you want to refine the parameters, create an NSDictionary and call this method
// see htpp://api.vid.ly for more options
- (void)sendQueryWithDictionary:(NSDictionary*)dictionary;
// or you can pass the raw XML to this method
// see htpp://api.vid.ly for more options
- (void)sendQueryWithXMLBody:(NSString*)xmlString;

@end
