//
//  SpotlightHandler.m
//  Swipes
//
//  Created by demosten on 7/28/15.
//  Copyright © 2015 Pihl IT. All rights reserved.
//

@import MobileCoreServices;
@import CoreSpotlight;
#import "Global.h"
#import "KPToDo.h"
#import "SpotlightHandler.h"

NSString * const kSwipesIdentifier = @"swipes_corespotlight";

@implementation SpotlightHandler

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        if (![USER_DEFAULTS objectForKey:kSwipesIdentifier]) {
            [self reset];
        }
    }
    return self;
}

- (void)clearAll
{
    [[CSSearchableIndex defaultSearchableIndex] deleteAllSearchableItemsWithCompletionHandler:^(NSError * _Nullable error) {
        DLog(@"deleteAllSearchableItemsWithCompletionHandler: %@", error);
        if (error) {
            // TODO log
        }
    }];
    [USER_DEFAULTS removeObjectForKey:kSwipesIdentifier];
    [USER_DEFAULTS synchronize];
}

- (void)setTodoItem:(KPToDo *)todo
{
    if (nil == todo.parent) {
        // this is a high level TODO
        // Create an attribute set for an item that represents an image.
        CSSearchableItemAttributeSet* attributeSet = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:(NSString*)kUTTypeCompositeContent];
        // Set properties that describe attributes of the item such as title, description, and image.
        [attributeSet setTitle:todo.title];
        if (todo.tags) {
            [attributeSet setContentDescription:[NSString stringWithFormat:@"%@", todo.tags]];
        }
//        UIImage* image = [UIImage imageNamed:@"logo"];
//        if (image) {
//            [attributeSet setThumbnailData:UIImageJPEGRepresentation(image, 0.7f)];
//        }
        
//        NSString* path = [[NSBundle mainBundle] pathForResource:@"logo" ofType:@"png" inDirectory:@"Assets"];
//        if (path) {
//            NSURL* imageURL = [NSURL fileURLWithPath:path];
//            [attributeSet setThumbnailURL:imageURL];
//        }
        
        // Create a searchable item, specifying its ID, associated domain, and attribute set.
        CSSearchableItem* item = [[CSSearchableItem alloc] initWithUniqueIdentifier:todo.tempId domainIdentifier:kSwipesIdentifier attributeSet:attributeSet];
        
        // Index the item.
        [[CSSearchableIndex defaultSearchableIndex] indexSearchableItems:@[item] completionHandler: ^(NSError * __nullable error) {
            DLog(@"indexSearchableItems: %@", error);
           // TODO log
        }];
    }
}

- (void)setAll
{
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_defaultContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(isLocallyDeleted <> YES)"];
    NSArray<KPToDo *> *results = [KPToDo MR_findAllWithPredicate:predicate inContext:localContext];
    [[CSSearchableIndex defaultSearchableIndex] beginIndexBatch];
    for (KPToDo* todo in results) {
        [self setTodoItem:todo];
    }
    [[CSSearchableIndex defaultSearchableIndex] endIndexBatchWithClientState:[NSData new] completionHandler:^(NSError * _Nullable error) {
        DLog(@"endIndexBatchWithClientState: %@", error);
        // TODO log
    }];
    [USER_DEFAULTS setObject:@(YES) forKey:kSwipesIdentifier];
    [USER_DEFAULTS synchronize];
}

- (void)reset
{
    UIApplicationState state = [UIApplication sharedApplication].applicationState;
    if (UIApplicationStateActive == state) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            [self clearAll];
            [self setAll];
        });
    }
}

@end
