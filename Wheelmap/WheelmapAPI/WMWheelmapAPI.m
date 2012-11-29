//
//  WMWheelmapAPI.m
//  Wheelmap
//
//  Created by Dorian Roy on 06.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMWheelmapAPI.h"
#import "AFJSONRequestOperation.h"


@implementation WMWheelmapAPI


- (id)initWithBaseURL:(NSURL *)url apiKey:(NSString*)apiKey {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    // use JSON requests per default
    // TODO: test that other requests will be routed to different operation classes
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    // make sure status code 304 is treated as success
    // 304 is returned when an eTag matched the version on the server, which
    // indicates that the local data is current and no data transfer necessary
    [AFHTTPRequestOperation addAcceptableStatusCodes:[NSIndexSet indexSetWithIndex:304]];
    
	[self setDefaultHeader:@"Accept" value:@"application/json"];
    [self setDefaultHeader:@"X-API-KEY" value:apiKey];
    
    return self;
}

- (NSOperation*) requestResource:(NSString *)resource
              parameters:(NSDictionary *)parameters
                    eTag:(NSString *)eTag
                    data:(id)data
                  method:(NSString *)method
                   error:(void(^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))errorBlock
                 success:(void(^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))successBlock
        startImmediately:(BOOL)startImmediately
{
    NSMutableURLRequest *request = [self requestWithMethod:method?:@"GET" path:resource parameters:parameters];
    
    // set If-None-Match header if an eTag is provided
    if (eTag) [request setValue:eTag forHTTPHeaderField:@"If-None-Match"];
    
    // add body
    [request setHTTPBody:data];
    
    // create request operation
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:successBlock failure:errorBlock];
    
    // start if necessary
    if (startImmediately) [operation start];
    
    return operation;
}



@end



