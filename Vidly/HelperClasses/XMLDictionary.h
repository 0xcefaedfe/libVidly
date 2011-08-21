//
//  XMLDictionary.h
//
//  Created by Tamas Zsar on 2011.04.17..
//  Copyright 2011 encoding.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMLDictionary : NSObject <NSXMLParserDelegate> {
    NSMutableArray *stack;
    NSMutableString *inProgress;
}

+ (NSDictionary *)dictionaryForXMLString:(NSString *)string;
+ (NSString *)XMLStringForDictionary:(NSDictionary*)dictionary;

@end
