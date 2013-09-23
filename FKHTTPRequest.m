//
//  FKHTTPRequest.m
//  FKHTTPRequest
//
//  Created by Rolando Abarca on 9/22/13.
//  Copyright (c) 2013 Rolando Abarca. All rights reserved.
//

#import "FKHTTPRequest.h"

@interface NSString (URLEncode)
- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding;
@end

@implementation NSString (URLEncode)
- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding {
	return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
																				 (CFStringRef)self,
																				 NULL,
																				 (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
																				 CFStringConvertNSStringEncodingToEncoding(encoding)));
}
@end

@interface FKHTTPRequest () {
	NSMutableURLRequest* _request;
	NSHTTPURLResponse* _urlResponse;
}

@end

@implementation FKHTTPRequest

- (id)initWithURL:(NSURL*)url {
	self = [super init];
	if (self) {
		_request = [NSMutableURLRequest requestWithURL:url];
		_method = @"GET";
		_urlResponse = nil;
	}
	return self;
}

- (void)setValue:(NSString *)value forHeader:(NSString *)header {
	[_request setValue:value forKey:header];
}

- (void)sendWithCompletion:(void (^)(int status, id response, NSError* error))completion {
	// first, prepare the data
	if (_postData) {
		NSMutableArray* values = [[NSMutableArray alloc] init];
		[_postData enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
			NSString* str = [NSString stringWithFormat:@"%@=%@",
							 [key urlEncodeUsingEncoding:NSASCIIStringEncoding],
							 [obj urlEncodeUsingEncoding:NSASCIIStringEncoding]];
			[values addObject:str];
		}];
		NSString* rawData = [values componentsJoinedByString:@"&"];
		_request.HTTPBody = [NSData dataWithBytes:[rawData UTF8String] length:[rawData length]];
		[_request setValue:@"application/x-www-form-urlencoded" forKey:@"content-type"];
	}
	_request.HTTPMethod = _method;
	if (completion) {
		[NSURLConnection sendAsynchronousRequest:_request
										   queue:[NSOperationQueue mainQueue]
							   completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
			if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
				_urlResponse = (NSHTTPURLResponse*)response;
				NSRange rg = [[_urlResponse.allHeaderFields objectForKey:@"Content-Type"] rangeOfString:@"application/json"];
				if (rg.location != NSNotFound) {
					// it's a json response, try to conver that to json
					NSError* error;
					id obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
					if (obj && !error) {
						completion(_urlResponse.statusCode, obj, nil);
					} else {
						completion(_urlResponse.statusCode, data, connectionError);
					}
				} else {
					completion(_urlResponse.statusCode, data, connectionError);
				}
			}
		}];
	} else {
		NSHTTPURLResponse* response;
		NSError* error;
		_response = [NSURLConnection sendSynchronousRequest:_request returningResponse:&response error:&error];
		_urlResponse = response;
	}
}

- (id)jsonResponse {
	NSError* error;
	id obj = [NSJSONSerialization JSONObjectWithData:_response options:0 error:&error];
	if (obj && !error) {
		return obj;
	}
	return nil;
}

- (int)status {
	return _urlResponse.statusCode;
}

+ (FKHTTPRequest*)requestWithURL:(NSURL *)url postData:(NSDictionary *)postData {
	return [FKHTTPRequest requestWithURL:url postData:postData completion:nil];
}

+ (FKHTTPRequest*)requestWithURL:(NSURL *)url postData:(NSDictionary *)postData completion:(void (^)(int, id, NSError *))completion {
	FKHTTPRequest* req = [[FKHTTPRequest alloc] initWithURL:url];
	req.method = (postData ? @"POST" : @"GET");
	[req sendWithCompletion:completion];
	return req;
}

@end
