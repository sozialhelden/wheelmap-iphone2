//
//  WMDataParser.h
//  Wheelmap
//
//  Created by Dorian Roy on 03.01.13.
//  Copyright (c) 2013 Sozialhelden e.V. All rights reserved.
//


@interface WMDataParser : NSObject

@property (nonatomic) NSManagedObjectContext* managedObjectContext;

- (id) initWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext;

- (id) parseDataObject:(id)object entityName:(NSString*)entityName error:(NSError**)error;

@end

enum {
    WMDataParserManagedObjectCreationError,
    WMDataParserInvalidUserKeyError,
    WMDataParserInvalidRemoteDataError
};

extern NSString *WMDataParserErrorDomain;