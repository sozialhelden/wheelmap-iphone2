//
//  WMWheelmapAPI.h
//  Wheelmap
//
//  Created by Dorian Roy on 06.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WMWheelmapAPI : AFHTTPClient

@property (nonatomic, strong) Reachability* internetReachable;

+ (WMWheelmapAPI *)sharedInstance;

- (id) initWithBaseURL:(NSURL *)url;

	
- (NSOperation*) requestResource:(NSString *)resource
                          apiKey:(NSString*)apiKey
                      parameters:(NSDictionary *)parameters
                            eTag:(NSString *)eTag
                          method:(NSString *)method
                           error:(void(^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))errorBlock
                         success:(void(^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))successBlock
                    startImmediately:(BOOL)startImmediately;

- (NSOperation *) downloadFile:(NSURL *)url
                        toPath:(NSString*)path
                         error:(void(^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))errorBlock
                       success:(void(^)(NSURLRequest *request, NSHTTPURLResponse *response))successBlock
              startImmediately:(BOOL)startImmediately;

- (NSOperation *) uploadImage:(UIImage *)image
                       nodeID:(NSNumber *)nodeID
                       apiKey:(NSString *)apiKey
                        error:(void (^)(NSURLRequest *, NSHTTPURLResponse *, NSError *, id))errorBlock
                      success:(void (^)(NSURLRequest *, NSHTTPURLResponse *, id))successBlock
             startImmediately:(BOOL)startImmediately;

#pragma mark - Helper

+ (NSString *)baseUrl;

+ (BOOL)isStagingBackend;

@end
