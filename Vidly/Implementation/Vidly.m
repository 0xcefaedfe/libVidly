//
//  libVidly.m
//  libVidly
//
//  Created by Tamas Zsar on 2011.08.20..
//  Copyright 2011 encoding.com. All rights reserved.
//

#import "Vidly.h"
#import "XMLDictionary.h"

#define BASE_URL @"https://m.vid.ly/api/"

static NSString *errorDomain = @"ly.vid.api";

@implementation Vidly
@synthesize userID = _userID;
@synthesize userKey = _userKey;
@synthesize notifyURL = _notifyURL;
@synthesize delegate = _delegate;
@synthesize status = _status;

#pragma mark -
#pragma mark initializers

- (id)initWithUserID:(NSString*)userID userKey:(NSString*)userKey andDelegate:(id<VidlyDelegate>)delegate {
    self = [super init];
    if (self) {
        self.userID = userID;
        self.userKey = userKey;
        self.delegate = delegate;
    }
    return self;
}

#pragma mark -
#pragma mark query

- (void)sendQueryWithDictionary:(NSDictionary*)dictionary {
    NSString *xmlString = [XMLDictionary XMLStringForDictionary:dictionary];
    // xmlString is nil if the dictionart could not be parsed
    if (!xmlString) {
        NSDictionary *errorDictionary = [NSDictionary dictionaryWithObject:@"Invalid parameter dictionary" forKey:@"description"];
        NSError *error = [NSError errorWithDomain:errorDomain code:VidlyErrorInvalidParameterDictionary userInfo:errorDictionary];
        if ([_delegate respondsToSelector:@selector(vidly:didFailedWithError:)]) {
            [_delegate vidly:self didFailedWithError:error];
        }
        return;
    }
    
    // all's well, send the request
    [self sendQueryWithXMLBody:xmlString];
}

- (void)sendQueryWithXMLBody:(NSString*)xmlString {
    if (_status != VidlyConnectionStatusReady) {
        if ([_delegate respondsToSelector:@selector(vidly:didFailedWithError:)]) {
            NSDictionary *errorDictionary = [NSDictionary dictionaryWithObject:@"A connection is already running" forKey:@"description"];
            NSError *error = [NSError errorWithDomain:errorDomain code:VidlyErrorConnectionFailed userInfo:errorDictionary];
            [_delegate vidly:self didFailedWithError:error];
        }
        return;
    }
    
    if (_userID == nil || _userKey == nil) {
        if ([_delegate respondsToSelector:@selector(vidly:didFailedWithError:)]) {
            NSDictionary *errorDictionary = [NSDictionary dictionaryWithObject:@"userID or userKey is nil" forKey:@"description"];
            NSError *error = [NSError errorWithDomain:errorDomain code:VidlyErrorConnectionFailed userInfo:errorDictionary];
            [_delegate vidly:self didFailedWithError:error];
        }
        return;
    }
    
    // create POST data
    NSMutableString *postString = [[NSMutableString alloc] initWithString:@"xml="];
    [postString appendFormat:@"<?xml version=\"1.0\"?><Query><UserID>%@</UserID><UserKey>%@</UserKey>", _userID, _userKey];
    if (_notifyURL) {
        [postString appendFormat:@"<Notify>%@</Notify>", _notifyURL];
    }
    [postString appendFormat:@"%@</Query>", xmlString];
    
    NSData *postData = [postString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];    
    
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:BASE_URL]];
	[request setHTTPMethod:@"POST"];
	[request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
	// create data
	_data = [[NSMutableData alloc] init];
	
	// create new connection
	_urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
	// start connection
	[_urlConnection start];
    _status = VidlyConnectionStatusRunning;
    [postString release];
}

- (void)addMedia:(NSArray*)sourceURLs {
    NSMutableString *xmlString = [[NSMutableString alloc] initWithString:@"<Action>AddMedia</Action>"];
    for (NSString *sourceURL in sourceURLs) {
        [xmlString appendFormat:@"<Source><SourceFile>%@</SourceFile></Source>", sourceURL];
    }
    [self sendQueryWithXMLBody:xmlString];
    [xmlString release];
}

- (void)deleteMedia:(NSArray*)mediaShortLinks {
    NSMutableString *xmlString = [[NSMutableString alloc] initWithString:@"<Action>DeleteMedia</Action>"];
    for (NSString *mediaShortLink in mediaShortLinks) {
        [xmlString appendFormat:@"<MediaShortLink>%@</MediaShortLink>", mediaShortLink];
    }
    [self sendQueryWithXMLBody:xmlString];
    [xmlString release];    
}

- (void)getStatus:(NSArray*)mediaShortLinks {
    NSMutableString *xmlString = [[NSMutableString alloc] initWithString:@"<Action>GetStatus</Action>"];
    for (NSString *mediaShortLink in mediaShortLinks) {
        [xmlString appendFormat:@"<MediaShortLink>%@</MediaShortLink>", mediaShortLink];
    }
    [self sendQueryWithXMLBody:xmlString];
    [xmlString release];    
    
}

#pragma mark -
#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[_data appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    _status = VidlyConnectionStatusFailed;
    [_data release], _data = nil;
	if ([_delegate respondsToSelector:@selector(vidly:didFailedWithError:)]) {
        NSError *vidlyError = [NSError errorWithDomain:errorDomain code:VidlyErrorConnectionFailed userInfo:error.userInfo];
		[_delegate vidly:self didFailedWithError:vidlyError];
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	// parse response
	NSString *responseString = [[NSString alloc] initWithBytes:[_data bytes] length:[_data length] encoding:NSUTF8StringEncoding];
	
	// create response dictionary
	NSDictionary *results = nil;
	results = [XMLDictionary dictionaryForXMLString:responseString];
    
	if ([_delegate respondsToSelector:@selector(vidly:didReceiveResponse:)]) {
		[_delegate vidly:self didReceiveResponse:results];
	}
    _status = VidlyConnectionStatusReady;
    [_data release], _data = nil;    
    [responseString release];
}


#pragma mark -
#pragma mark memory management

- (void)dealloc {
    self.userID = nil;
    self.userKey = nil;
    self.delegate = nil;
    [super dealloc];
}

@end
