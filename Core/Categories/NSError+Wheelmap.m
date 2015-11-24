//
//  NSError+Wheelmap.m
//  Wheelmap
//
//  Created by Hans Seiffert on 30.10.15.
//
//

#import "NSError+Wheelmap.h"

@implementation NSError (Wheelmap)

/*
  Returns one error message from the response. The response looks like this:
  "NSLocalizedRecoverySuggestion = "{\"error\":{\"phone\":[\"Telefonnumer ist nicht korrekt. Die Telefonnummer muss im folgenden Format eingegeben werden: +49 30 234567\"]}}".
 */
- (NSString *)wheelmapErrorDescription {
	NSString *responseString =  self.userInfo[NSLocalizedRecoverySuggestionErrorKey];
	if (responseString != nil) {
		// Convert the error response to JSON
		id json = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
		if (json != nil && [json isKindOfClass:[NSDictionary class]]) {
			// Get the error values
			NSDictionary *errorMessagesDict = ((NSDictionary*)json)[@"error"];
			if (errorMessagesDict != nil && errorMessagesDict.allValues.count > 0) {
				// Get the first error and return it's value (the error message)
				NSArray *errorMessageArray = errorMessagesDict.allValues.firstObject;
				if ([errorMessageArray isKindOfClass:[NSArray class]] && errorMessageArray.count > 0) {
					return errorMessageArray.firstObject;
				}
			}
		}
	}
	return nil;
}

@end
