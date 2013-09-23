//
//  FKHTTPRequest.h
//  FKHTTPRequest
//
//  Created by Rolando Abarca on 9/22/13.
//  Copyright (c) 2013 Rolando Abarca. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FKHTTPRequest : NSObject

@property (nonatomic,strong) NSDictionary* postData;
@property (nonatomic,strong) NSString* method;
@property (nonatomic,strong) NSString* contentType;
@property (nonatomic,strong) NSData* response;

/**
 * Synchronous version
 */
+ (FKHTTPRequest*)requestWithURL:(NSURL*)url postData:(NSDictionary*)postData;

/**
 * Asynchronous version. The completion block will get called in the main queue
 */
+ (FKHTTPRequest*)requestWithURL:(NSURL*)url postData:(NSDictionary*)postData completion:(void (^)(int status, id response, NSError* error))completion;

- (id)initWithURL:(NSURL*)url;
- (void)sendWithCompletion:(void (^)(int status, id response, NSError* error))completion;
- (void)setValue:(NSString*)value forHeader:(NSString*)header;
- (id)jsonResponse;
- (int)status;
@end
