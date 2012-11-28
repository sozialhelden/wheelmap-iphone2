//
//  Image.h
//  Wheelmap
//
//  Created by Dorian Roy on 28.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo;

@interface Image : NSManagedObject

@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) Photo *photo;

@end
