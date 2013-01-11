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


+ (WMWheelmapAPI *)sharedInstance
{
    static WMWheelmapAPI *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[WMWheelmapAPI alloc] initWithBaseURL:[NSURL URLWithString:WMBaseURL]];
    });
    
    return _sharedInstance;
}

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    // use JSON requests per default
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    // make sure status code 304 is treated as success
    // 304 is returned when an eTag matched the version on the server, which
    // indicates that the local data is current and no data transfer necessary
    [AFHTTPRequestOperation addAcceptableStatusCodes:[NSIndexSet indexSetWithIndex:304]];
    
	[self setDefaultHeader:@"Accept" value:@"application/json"];
    
    return self;
}

- (NSOperation*) requestResource:(NSString *)resource
                          apiKey:(NSString *)apiKey
                      parameters:(NSDictionary *)parameters
                            eTag:(NSString *)eTag
                          method:(NSString *)method
                           error:(void (^)(NSURLRequest *, NSHTTPURLResponse *, NSError *, id))errorBlock
                         success:(void (^)(NSURLRequest *, NSHTTPURLResponse *, id))successBlock
                startImmediately:(BOOL)startImmediately
{
    NSMutableURLRequest *request = [self requestWithMethod:method?:@"GET" path:resource parameters:parameters];
    
    if (apiKey) [request setValue:apiKey forHTTPHeaderField:@"X-API-KEY"];
    
    if (eTag) [request setValue:eTag forHTTPHeaderField:@"If-None-Match"];
    
    // create request operation
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:successBlock failure:errorBlock];
    
    // start if necessary
    if (startImmediately) [self enqueueHTTPRequestOperation:operation];
    
    return operation;
}

- (NSOperation *) downloadFile:(NSURL *)url
                        toPath:(NSString*)path
                         error:(void(^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))errorBlock
                       success:(void(^)(NSURLRequest *request, NSHTTPURLResponse *response))successBlock
              startImmediately:(BOOL)startImmediately
{
    // create basic http operation
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    // stream to destination file path
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
    
    // set result blocks that call our standard result blocks
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *op, id response) {
                                            successBlock(request, response);
                                        }
                                     failure:^(AFHTTPRequestOperation *op , NSError *error) {
                                            errorBlock(request, op.response, error);
                                        }
    ];
    
    // start if necessary
    if (startImmediately) [self enqueueHTTPRequestOperation:operation];
    
    return operation;
}

- (NSOperation *) uploadImage:(UIImage *)image
                           nodeID:(NSNumber *)nodeID
                           apiKey:(NSString *)apiKey
                            error:(void (^)(NSURLRequest *, NSHTTPURLResponse *, NSError *, id))errorBlock
                        success:(void (^)(NSURLRequest *, NSHTTPURLResponse *, id))successBlock
                 startImmediately:(BOOL)startImmediately
{
    // get path where the image file should be saved
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *rootPath = [paths objectAtIndex:0];
    NSString* destinationPath = [rootPath stringByAppendingPathComponent:@"upload_image.jpg"];
    
    NSData* data = UIImageJPEGRepresentation(image, 1.0);
    [data writeToFile:destinationPath atomically:YES];
    
    NSMutableURLRequest* request = [self multipartFormRequestWithMethod:@"POST" path:[NSString stringWithFormat:@"nodes/%@/photos", nodeID] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:@"photo" fileName:@"upload_image.jpg" mimeType:@"image/jpg"];
    }];
    
    if (apiKey) [request setValue:apiKey forHTTPHeaderField:@"X-API-KEY"];
    
    // create request operation
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:successBlock failure:errorBlock];
    
    // start if necessary
    if (startImmediately) [self enqueueHTTPRequestOperation:operation];
    
    return operation;

}


@end





