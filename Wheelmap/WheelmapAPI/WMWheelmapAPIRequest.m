//
//  WMWheelmapAPIRequest.m
//  Wheelmap
//
//  Created by Dorian Roy on 06.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMWheelmapAPIRequest.h"


@implementation WMWheelmapAPIRequest
{
    NSURLConnection *connection;
    void (^errorHandler)(NSError*);
    void (^successHandler)(id, NSString*);
    NSHTTPURLResponse* response;
    NSMutableData *data;
}

- (id) initWithURLRequest:(NSURLRequest *)request error:(void (^)(NSError *))errorBlock success:(void (^)(id, NSString*))successBlock
{
    self = [super init];
    if (self) {
        errorHandler = errorBlock;
        successHandler = successBlock;
        connection = [NSURLConnection connectionWithRequest:request delegate:self];
    }
    return self;
}


#pragma mark - Connection Data Delegate

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)responseParam
{
    response = (NSHTTPURLResponse*)responseParam;
    data = [[NSMutableData alloc] init];
}

- (void) connection:(NSURLConnection *)connectionParam didFailWithError:(NSError *)error
{
    errorHandler(error);
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)dataParam
{
    [data appendData:dataParam];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connectionParam
{
    // parse json
    NSError *parseError = nil;
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                               options:0
                                                                 error:&parseError];

    // allocate error
    NSError *error = nil;
    
    // if json couldn't be parsed
    if (!jsonObject) {
        error = [NSError errorWithDomain:@"WMAPIError"
                                    code:0
                                userInfo:@{NSUnderlyingErrorKey:parseError}];
        
    // if request received http error code
    } else if ([response statusCode] / 100 != 2) {
       
        error = [NSError errorWithDomain:@"WMAPIError"
                                    code:[response statusCode]
                                userInfo:nil];
    }
    
    if (error) {
        errorHandler(error);
        
    } else {
        NSDictionary *headers = [response allHeaderFields];
        NSString *eTag = [(NSString*)headers[@"ETag"] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        successHandler(jsonObject, eTag);
    }
}


@end

