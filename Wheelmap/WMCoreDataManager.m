//
//  WMCoreDataManager.m
//  Wheelmap
//
//  Created by Dorian Roy on 27.11.12.
//  Copyright (c) 2012 Sozialhelden e.V. All rights reserved.
//

#import "WMCoreDataManager.h"
#import <CoreData/CoreData.h>

@implementation WMCoreDataManager


/**
 Returns a single instance of a managed object context.
 If the context doesn't already exist, it is created with the preset
 database name and bound to a SQLite persistent store.
 */
+ (NSManagedObjectContext*) managedObjectContext
{
    // create single instance of managed object context
    static NSManagedObjectContext *managedObjectContext = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] init];
        
        // create model
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"EFBDataModel" withExtension:@"momd"];
        NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        
        // create store coordinator
        NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
        
        // get store URL
        NSURL *applicationDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        NSURL *persistentStoreURL = [applicationDocumentsDirectory URLByAppendingPathComponent:@"EFBDatabase.sqlite"];
        
        NSError *error = nil;
        // if we can't add store to coordinator...
        if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                      configuration:nil
                                                                URL:persistentStoreURL
                                                            options:nil
                                                              error:NULL]) {
            
            // ... we ignore the error, and if the file already exists but is not compatible, we try to replace it with a new store file
            if ([[NSFileManager defaultManager] fileExistsAtPath:persistentStoreURL.path]) {
                
                // get metadata of existing store
                NSDictionary *metaData = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType URL:persistentStoreURL error:NULL];
                
                // if meta data can't be read or model is not compatible
                if (!metaData || ![managedObjectModel isConfiguration:nil compatibleWithStoreMetadata:metaData]) {
                    
                    // if old store file can be removed
                    if ([[NSFileManager defaultManager] removeItemAtPath:persistentStoreURL.path error:&error]) {
                        
                        // try to add new store
                        [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                 configuration:nil
                                                                           URL:persistentStoreURL
                                                                       options:nil
                                                                         error:&error];
                    }
                }
            }
        }
        
        if (error) {
            // this is an unrecoverable error, so we show an alert and crash
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Fatal Error" message:@"Could not create local database" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            
        } else {
            // assign coordinator to context
            [moc setPersistentStoreCoordinator:persistentStoreCoordinator];
            
            // save context in the static variable
            managedObjectContext = moc;
        }
    });
    
    return managedObjectContext;
}

+ (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    abort();
}

@end
