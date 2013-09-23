# FKHTTPRequest

A very simple & minimalistic wrapper around NSURLConnection & friends.

# Usage

```objective-c
#import "FKHTTPRequest.h"

...

// asynchronous
[FKHTTPRequest requestWithURL:myService postData:@{@"ifa": ifa.UUIDString} completion:^(int status, id response, NSError *error) {
    if (status == 200) {
	    // response is either NSData or NSDictionary if Content-Type is application/json
		if ([response isKindOfClass:[NSDictionary class]]) {
		    // do something with response here
		}
	}
}];

// synchronous
FKHTTPRequest* req = [FKHTTPRequest requestWithURL:url postData:formData];
if (req.status == 200) {
    NSDictionary* response = req.jsonResponse;
	if (response) {
	    // it's a valid json response, otherwise, we can use req.response, which is NSData
	}
}
```

# License

do-whatever-you-want-with-this-license.
