//
//  WMWheelmapAPI.m
//  Wheelmap
//
//  Created by Dorian Roy on 06.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMWheelmapAPI.h"
#import "AFJSONRequestOperation.h"


#define WMBaseURL @"http://staging.wheelmap.org/api"
#define WMAPIKey @"your api key here"


@implementation WMWheelmapAPI

- (NSOperation*) requestResource:(NSString *)resource
              parameters:(NSDictionary *)parameters
                    eTag:(NSString *)eTag
                    data:(id)data
                  method:(NSString *)method
                   error:(void(^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))errorBlock
                 success:(void(^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))successBlock
        startImmediately:(BOOL)startImmediately
{
    // create parameter string from parameter dictionary
    __block NSMutableString *parameterString;
    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        if (!parameterString) parameterString = [NSMutableString stringWithString:@"?"];
        else [parameterString appendString:@"&"];
        
        // escape value string
        NSString *escapedString = (__bridge NSString*)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)[parameters valueForKey:key], NULL, CFSTR(":/?#[]@!$&’()*+,;="), kCFStringEncodingUTF8);
        [parameterString appendFormat:@"%@=%@", key, escapedString];
    }];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@%@", WMBaseURL, resource, parameterString ?: @""];
    
    // create URL for resource
    NSURL *url = [NSURL URLWithString:urlString relativeToURL:[NSURL URLWithString:WMBaseURL]];
    
    // create request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:method ?: @"GET"];
    [request setHTTPBody:data];
    
    // set api key
    [request setValue:WMAPIKey forHTTPHeaderField:@"X-API-KEY"];
    
    // set eTag if necessary
    if (eTag) [request setValue:eTag forHTTPHeaderField:@"ETag"];
    
    // create request operation
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:successBlock failure:errorBlock];
    
    // start if necessary
    if (startImmediately) [operation start];
    
    return operation;
}



@end
