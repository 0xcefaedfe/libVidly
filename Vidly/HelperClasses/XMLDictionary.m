//
//  XMLDictionary.m
//
//  Created by Tamas Zsar on 2011.04.17..
//  Copyright 2011 encoding.com. All rights reserved.
//

#import "XMLDictionary.h"

@interface XMLDictionary (internal)
// internal methods
- (NSDictionary *)objectWithString:(NSString *)string;

@end


@implementation XMLDictionary

#pragma mark -
#pragma mark class methods

+ (NSDictionary *)dictionaryForXMLString:(NSString *)string {
	XMLDictionary *reader = [[XMLDictionary alloc] init];
	NSDictionary *rootDictionary = [reader objectWithString:string];
	[reader release];
	return rootDictionary;
}

+ (NSString *)XMLStringForDictionary:(NSDictionary*)dictionary {
	NSMutableString *xmlString = [[[NSMutableString alloc] init] autorelease];
	for (NSString *key in [dictionary allKeys]) {
		id item = [dictionary objectForKey:key];
		if ([item isKindOfClass:[NSString class]]) {
			[xmlString appendFormat:@"<%@>%@</%@>", key, item, key];
		}
		
		if ([item isKindOfClass:[NSDictionary class]]) {
			[xmlString appendFormat:@"<%@>%@</%@>", key, [XMLDictionary XMLStringForDictionary:item], key];
		}
	}
	return xmlString;
}

#pragma mark -
#pragma mark Parsing

- (NSDictionary *)objectWithString:(NSString *)string {
	NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];

	// clean up
	[stack release];
	[inProgress release];
	
	stack = [[NSMutableArray alloc] init];
	inProgress = [[NSMutableString alloc] init];
	
	// initialize stack
	[stack addObject:[NSMutableDictionary dictionary]];
	
	// parse xml
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
	parser.delegate = self;
	BOOL success = [parser parse];
	
	if (success) {
		NSDictionary *resultDict = [stack objectAtIndex:0];
		return resultDict;
	}
	
	return nil;
}

#pragma mark -
#pragma mark NSXMLParserDelegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	// get current level
	NSMutableDictionary *parentDict = [stack lastObject];

	// create child dictionary
	NSMutableDictionary *childDict = [NSMutableDictionary dictionary];
	[childDict addEntriesFromDictionary:attributeDict];
	
	// if we already have this item, create an array
	id value = [parentDict objectForKey:elementName];
	if (value) {
		NSMutableArray *array = nil;
		if ([value isKindOfClass:[NSMutableArray class]]) {
			array = (NSMutableArray *) value;
		}
		else {
			array = [NSMutableArray array];
			[array addObject:value];

			[parentDict setObject:array forKey:elementName];
		}
		[array addObject:childDict];
	}
	else {
		[parentDict setObject:childDict forKey:elementName];
	}
	
	// update the stack
	[stack addObject:childDict];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	NSMutableDictionary *dictInProgress = [stack lastObject];
	
	// set the text property
	if ([inProgress length] > 0) {
		[dictInProgress setObject:inProgress forKey:@"text"];
		
		[inProgress release];
		inProgress = [[NSMutableString alloc] init];
	}

	[stack removeLastObject];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	[inProgress appendString:string];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	
}

#pragma mark -
#pragma mark memory management

- (void)dealloc {
	[stack release];
	[inProgress release];
	[super dealloc];
}

@end
