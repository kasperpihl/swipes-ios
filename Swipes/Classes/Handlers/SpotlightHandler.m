//
//  SpotlightHandler.m
//  Swipes
//
//  Created by demosten on 7/28/15.
//  Copyright © 2015 Pihl IT. All rights reserved.
//

#ifdef __IPHONE_9_0

@import MobileCoreServices;
@import CoreSpotlight;
#import "Global.h"
#import "KPToDo.h"
#import "KPTag.h"
#import "KPAttachment.h"
#import "NSDate-Utilities.h"
#import "RootViewController.h"
#import "UtilityClass.h"
#import "SpotlightHandler.h"

NSString * const kSwipesIdentifier = @"swipes_corespotlight";

typedef NS_ENUM(NSUInteger, IMAGE_TYPES)
{
    SCHEDULE_IMAGE = 0,
    TODAY_IMAGE,
    DONE_IMAGE
};

@interface SpotlightHandler () <CSSearchableIndexDelegate>

@property (nonatomic, strong) CSSearchableIndex* index;

@end

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
        if (OSVER >= 9) {
            _index = [[CSSearchableIndex alloc] initWithName:kSwipesIdentifier];
            _index.indexDelegate = self;
            if (![USER_DEFAULTS objectForKey:kSwipesIdentifier]) {
                [self resetWithCompletionHandler:nil];
            }
        }
    }
    return self;
}

- (void)clearAllWithCompletionHandler:(void (^ __nullable)(NSError * __nullable error))completionHandler
{
    if (OSVER >= 9) {
        [_index deleteAllSearchableItemsWithCompletionHandler:^(NSError * _Nullable error) {
            if (error) {
                [UtilityClass sendError:error type:@"CoreSpotlight: clearAllWithCompletionHandler"];
            }
            if (completionHandler)
                completionHandler(error);
        }];
        [USER_DEFAULTS removeObjectForKey:kSwipesIdentifier];
        [USER_DEFAULTS synchronize];
    }
    else {
        if (completionHandler)
            completionHandler(nil);
    }
}

- (NSURL *)imageURLForTodo:(KPToDo *)todo
{
    NSMutableString* name = [[NSMutableString alloc] initWithString:@"cs_"];
    NSDate* now = [NSDate date];
    if (((todo.schedule && [todo.schedule isLaterThanDate:now]) || (nil == todo.schedule && nil == todo.completionDate)) &&
        (nil == todo.parent)) {
        [name appendString:@"scheduled"];
    }
    else if (todo.completionDate) {
        [name appendString:@"done"];
    }
    else {
        [name appendString:@"today"];
    }
    
    if ([todo.priority boolValue] && (nil == todo.parent)) {
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
    // this is a high level TODO
    CSSearchableItemAttributeSet* attributeSet = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:(NSString*)kUTTypeToDoItem];
    // Set properties that describe attributes of the item such as title, description, and image.
    NSString* identifier;
    if (nil == todo.parent) {
        [attributeSet setTitle:todo.title];
        NSMutableArray<NSString *>* keywords = [NSMutableArray new];
        for (KPTag* tag in todo.tags) {
            [keywords addObject:tag.title];
        }
        
        for (KPAttachment* attachment in todo.attachments) {
            [keywords addObject:attachment.service];
        }
        
        if (keywords.count) {
            [attributeSet setKeywords:keywords];
        }
        if (todo.notes && 0 < todo.notes.length) {
            //[attributeSet setTextContent:todo.notes];
            [attributeSet setContentDescription:todo.notes];
        }
        identifier = todo.tempId;
    }
    else {
        identifier = [NSString stringWithFormat:@"%@:%@", todo.parent.tempId, todo.tempId];
        [attributeSet setTitle:todo.title];
        [attributeSet setContentDescription:[NSString stringWithFormat:@"• %@", todo.parent.title]];
    }

//    attributeSet.contentURL = [NSURL URLWithString:[NSString stringWithFormat:@"swipes://todo/view?id=%@", (nil == todo.parent) ? todo.tempId : todo.parent.tempId]];
    
//    UIImage* image = [self drawImageWithType:TODAY_IMAGE twoLine:NO priority:NO];
//    if (image) {
//        [attributeSet setThumbnailData:UIImagePNGRepresentation(image)];
//    }
//    
    NSURL* imageURL = [self imageURLForTodo:todo];
    if (imageURL) {
        [attributeSet setThumbnailURL:imageURL];
    }
    
    // Create a searchable item, specifying its ID, associated domain, and attribute set.
    CSSearchableItem* item = [[CSSearchableItem alloc] initWithUniqueIdentifier:identifier domainIdentifier:kSwipesIdentifier attributeSet:attributeSet];
    
    if (item) {
        // Index the item.
        [index indexSearchableItems:@[item] completionHandler: ^(NSError * __nullable error) {
            if (error) {
                [UtilityClass sendError:error type:@"CoreSpotlight: indexSearchableItems"];
            }
        }];
    }
}

- (void)setAllWithCompletionHandler:(void (^ __nullable)(NSError * __nullable error))completionHandler
{
    NSManagedObjectContext *contextForThread = [NSManagedObjectContext MR_contextForCurrentThread];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isLocallyDeleted <> YES"];
    NSArray<KPToDo *> *results = [KPToDo MR_findAllWithPredicate:predicate inContext:contextForThread];
    
    [_index beginIndexBatch];
    for (KPToDo* todo in results) {
        [self setTodoItem:todo index:_index];
    }
    [_index endIndexBatchWithClientState:[@"done" dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES] completionHandler:^(NSError * _Nullable error) {
        if (error) {
            [UtilityClass sendError:error type:@"CoreSpotlight: endIndexBatchWithClientState"];
        }
        if (completionHandler)
            completionHandler(error);
        DLog(@"CS: INDEXING DONE");
    }];
    [USER_DEFAULTS setObject:@(YES) forKey:kSwipesIdentifier];
    [USER_DEFAULTS synchronize];
}

- (void)resetWithCompletionHandler:(void (^ __nullable)(NSError * __nullable error))completionHandler
{
    if (OSVER >= 9) {
        UIApplicationState state = [UIApplication sharedApplication].applicationState;
        if (UIApplicationStateBackground != state) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self clearAllWithCompletionHandler:^(NSError * _Nullable error) {
                    [self setAllWithCompletionHandler:^(NSError * _Nullable error) {
                        if (completionHandler)
                            completionHandler(error);
                    }];
                }];
            });
        }
    }
    else {
        if (completionHandler)
            completionHandler(nil);
    }
}

- (void)restoreUserActivity:(NSUserActivity *)userActivity
{
    NSString* identifier = userActivity.userInfo[CSSearchableItemActivityIdentifier];
    if (identifier) {
        NSArray <NSString *>* components = [identifier componentsSeparatedByString:@":"];
        if (components.count) {
            NSArray* todos = [KPToDo findByTempId:components[0]];
            if (todos)
                [ROOT_CONTROLLER editToDo:todos[0]];
        }
    }
}

#pragma mark - CSSearchableIndexDelegate

- (void)searchableIndex:(CSSearchableIndex *)searchableIndex reindexAllSearchableItemsWithAcknowledgementHandler:(void (^)(void))acknowledgementHandler
{
    [self resetWithCompletionHandler:^(NSError * _Nullable error) {
        acknowledgementHandler();
    }];
}

- (void)searchableIndex:(CSSearchableIndex *)searchableIndex reindexSearchableItemsWithIdentifiers:(NSArray<NSString *> *)identifiers acknowledgementHandler:(void (^)(void))acknowledgementHandler
{
    [self resetWithCompletionHandler:^(NSError * _Nullable error) {
        acknowledgementHandler();
    }];
}

@end

#endif
