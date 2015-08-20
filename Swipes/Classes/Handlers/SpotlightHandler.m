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
#import "KPTag.h"
#import "NSDate-Utilities.h"
#import "SpotlightHandler.h"

NSString * const kSwipesIdentifier = @"swipes_corespotlight";
//NSString * const kSwipesIndex = @"swipes_index";

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
    if (OSVER >= 9) {
        CSSearchableIndex* index = [[CSSearchableIndex alloc] initWithName:kSwipesIdentifier];
        [index deleteAllSearchableItemsWithCompletionHandler:^(NSError * _Nullable error) {
            DLog(@"deleteAllSearchableItemsWithCompletionHandler: %@", error);
            if (error) {
                // TODO log
            }
        }];
        [USER_DEFAULTS removeObjectForKey:kSwipesIdentifier];
        [USER_DEFAULTS synchronize];
    }
}

- (NSURL *)imageURLForTodo:(KPToDo *)todo
{
    NSMutableString* name = [[NSMutableString alloc] initWithString:@"cs_"];
    NSDate* now = [NSDate date];
    if ((todo.schedule && [todo.schedule isLaterThanDate:now]) || (nil == todo.schedule && nil == todo.completionDate)) {
        [name appendString:@"scheduled"];
    }
    else if (todo.completionDate) {
        [name appendString:@"done"];
    }
    else {
        [name appendString:@"today"];
    }
    
    if ([todo.priority boolValue]) {
        [name appendString:@"_priority"];
    }
    
    if (nil != todo.parent) {
        [name appendString:@"_action"];
    }

    NSString* path = [[NSBundle mainBundle] pathForResource:name ofType:@"png" inDirectory:@"Assets/CoreSpotlight"];
    if (path) {
        return [NSURL fileURLWithPath:path];
    }

    return nil;
}

- (void)setTodoItem:(KPToDo *)todo index:(CSSearchableIndex *)index
{
    if (nil == todo.parent) {
        // this is a high level TODO
        // Create an attribute set for an item that represents an image.
        CSSearchableItemAttributeSet* attributeSet = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:(NSString*)kUTTypeCompositeContent];
        // Set properties that describe attributes of the item such as title, description, and image.
        [attributeSet setTitle:todo.title];
        NSMutableString* tagsString = [NSMutableString new];
        for (KPTag* tag in todo.tags) {
            if (tagsString.length) {
                [tagsString appendString:@", "];
            }
            [tagsString appendString:tag.title];
        }
        if (tagsString.length) {
            [attributeSet setContentDescription:tagsString];
        }
        
//        UIImage* image = [UIImage imageNamed:@"logo"];
//        if (image) {
//            [attributeSet setThumbnailData:UIImageJPEGRepresentation(image, 0.7f)];
//        }
        
        NSURL* imageURL = [self imageURLForTodo:todo];
        if (imageURL) {
            [attributeSet setThumbnailURL:imageURL];
        }
        
        // Create a searchable item, specifying its ID, associated domain, and attribute set.
        CSSearchableItem* item = [[CSSearchableItem alloc] initWithUniqueIdentifier:todo.tempId domainIdentifier:kSwipesIdentifier attributeSet:attributeSet];
        
        if (item) {
            // Index the item.
            [index indexSearchableItems:@[item] completionHandler: ^(NSError * __nullable error) {
                DLog(@"indexSearchableItems: %@", error);
               // TODO log
            }];
        }
    }
}

- (void)setAll
{
    NSManagedObjectContext *contextForThread = [NSManagedObjectContext MR_contextForCurrentThread];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(isLocallyDeleted <> YES)"];
    NSArray<KPToDo *> *results = [KPToDo MR_findAllWithPredicate:predicate inContext:contextForThread];
    
    CSSearchableIndex* index = [[CSSearchableIndex alloc] initWithName:kSwipesIdentifier];
    [index beginIndexBatch];
    for (KPToDo* todo in results) {
        [self setTodoItem:todo index:index];
    }
    [index endIndexBatchWithClientState:[@"done" dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES] completionHandler:^(NSError * _Nullable error) {
        DLog(@"endIndexBatchWithClientState: %@", error);
        // TODO log
    }];
    [USER_DEFAULTS setObject:@(YES) forKey:kSwipesIdentifier];
    [USER_DEFAULTS synchronize];
}

- (void)reset
{
    if (OSVER >= 9) {
        UIApplicationState state = [UIApplication sharedApplication].applicationState;
        if (UIApplicationStateBackground != state) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                [self clearAll];
                [self setAll];
            });
        }
    }
}

@end
