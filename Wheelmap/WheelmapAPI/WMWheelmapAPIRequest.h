//
//  WMWheelmapAPIRequest.h
//  Wheelmap
//
//  Created by Dorian Roy on 06.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WMWheelmapAPIRequest : NSObject<NSURLConnectionDataDelegate>

- (id) initWithURLRequest:(NSURLRequest*)request error:(void (^)(NSError*))errorBlock success:(void (^)(id))successBlock;


@end
