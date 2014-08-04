//
//  URLHandler.m
//  Swipes
//
//  Created by demosten on 7/28/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//
// Some test URLs
//
// swipes://todo/add?title=test&tag1=first%20tag&tag2=second%20tag&priority=1&notes=test%20note%0anew%20line&schedule=1406636343
// swipes://todo/add?title=test&schedule=now
// swipes://todo/update?oldtitle=test&title=test2&notes=
// swipes://todo/delete?title=test2
// swipes://tag/add?title=tag22
// swipes://tag/update?oldtitle=tag22&title=tag23
// swipes://tag/delete?title=tag23
// swipes://evernotetodo/add?guid=b2b35b4d-4c86-465d-8895-25160d9f9f21&tag1=first%20tag&tag2=second%20tag&priority=1&notes=test%20note%0anew%20line&schedule=1406636343
// swipes://evernotetodo/add?guid=b2b35b4d-4c86-465d-8895-25160d9f9f21
//

#import "NSURL+QueryDictionary.h"
#import "KPToDo.h"
#import "KPTag.h"
#import "KPAttachment.h"
#import "CoreSyncHandler.h"
#import "EvernoteIntegration.h"
#import "UtilityClass.h"
#import "RootViewController.h"
#import "URLHandler.h"

NSString* const kSwipesScheme = @"swipes";

NSString* const kSwipesDomainToDo = @"todo";
NSString* const kSwipesDomainTag = @"tag";
NSString* const kSwipesDomainEnToDo = @"evernotetodo";

NSString* const kSwipesCommandAdd = @"/add";
NSString* const kSwipesCommandUpdate = @"/update";
NSString* const kSwipesCommandDelete = @"/delete";

NSString* const kSwipesParamTitle = @"title";
NSString* const kSwipesParamOldTitle = @"oldtitle";
NSString* const kSwipesParamTag = @"tag";
NSString* const kSwipesParamPriority = @"priority";
NSString* const kSwipesParamNotes = @"notes";
NSString* const kSwipesParamSchedule = @"schedule";
NSString* const kSwipesParamGiud = @"guid";

@implementation URLHandler

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark - General methods

- (BOOL)handleURL:(NSURL *)url
{
    if ([url.scheme isEqualToString:kSwipesScheme]) {
        NSDictionary* query = [url uq_queryDictionary];
        if (nil != query) {
            if ([url.host isEqualToString:kSwipesDomainToDo]) {
                if ([url.path isEqualToString:kSwipesCommandAdd]) {
                    return [self handleAddToDo:query];
                }
                else if ([url.path isEqualToString:kSwipesCommandUpdate]) {
                    return [self handleUpdateToDo:query];
                }
                else if ([url.path isEqualToString:kSwipesCommandDelete]) {
                    return [self handleDeleteToDo:query];
                }
            }
            else if ([url.host isEqualToString:kSwipesDomainTag]) {
                if ([url.path isEqualToString:kSwipesCommandAdd]) {
                    return [self handleAddTag:query];
                }
                else if ([url.path isEqualToString:kSwipesCommandUpdate]) {
                    return [self handleUpdateTag:query];
                }
                else if ([url.path isEqualToString:kSwipesCommandDelete]) {
                    return [self handleDeleteTag:query];
                }
            }
            else if ([url.host isEqualToString:kSwipesDomainEnToDo]) {
                if ([url.path isEqualToString:kSwipesCommandAdd]) {
                    return [self handleAddEvernote:query];
                }
                else if ([url.path isEqualToString:kSwipesCommandDelete]) {
                    return [self handleDeleteToDo:query];
                }
            }
        }
    }
    return NO;
}

- (NSArray *)arrayFromQuery:(NSDictionary *)query withPrefix:(NSString *)prefix
{
    NSString* firstQuery = [NSString stringWithFormat:@"%@1", prefix];
    if (query[firstQuery] == (id)[NSNull null]) {
        return @[];
    }
    if (nil != query[firstQuery]) {
        NSMutableArray* result = [NSMutableArray array];
        for (NSUInteger i = 1; i < 255; i++) {
            NSString* data = query[[NSString stringWithFormat:@"%@%lu", prefix, (long)i]];
            if (nil != data) {
                [result addObject:data];
            }
            else {
                break;
            }
        }
        return result;
    }
    return nil;
}

- (NSDate *)dateFromString:(NSString *)data
{
    if (data) {
        if ([data isEqualToString:@"now"]) {
            return [NSDate date];
        }
        double d = [data doubleValue];
        if (1 < d && (HUGE_VAL - 1 > d)) {
            return [NSDate dateWithTimeIntervalSince1970:d];
        }
    }
    return [NSDate date];
}

#pragma mark - ToDos

- (void)doUpdateToDo:(KPToDo *)todo query:(NSDictionary *)query
{
    // keep in mind that 'param=&nextparam=test' means that param will be [NSNull null] which in our
    // url scheme means 'clear this'
    NSString* priority = query[kSwipesParamPriority];
    todo.priority = @(priority ? [priority boolValue] : NO);

    NSString* data = query[kSwipesParamNotes];
    if (data == (id)[NSNull null]) {
        todo.notes = nil;
    }
    else if (data) {
        todo.notes = data;
    }
    
    if (query[kSwipesParamSchedule] == (id)[NSNull null]) {
        todo.schedule = nil;
    }
    else {
        NSDate* date = [self dateFromString:query[kSwipesParamSchedule]];
        todo.schedule = date;
    }
    
    NSArray* tags = [self arrayFromQuery:query withPrefix:kSwipesParamTag];
    if (tags)
        [todo setTags:[NSSet setWithArray:tags]];
    
    [KPToDo saveToSync];
}

- (BOOL)handleAddToDo:(NSDictionary *)query
{
//    DLog(@"date: %f", [[NSDate dateWithTimeIntervalSinceNow:3600] timeIntervalSince1970]);
//    NSDate* d = [NSDate dateWithTimeIntervalSince1970:1406636343];
    NSString* title = query[kSwipesParamTitle];
    if (nil != title) {
        NSArray* todos = [KPToDo findByTitle:title];
        if (nil == todos) {
            KPToDo* todo = [KPToDo addItem:title priority:NO tags:[self arrayFromQuery:query withPrefix:kSwipesParamTag] save:NO];
            
            // remove tags
            NSMutableDictionary* mQuery = query.mutableCopy;
            [mQuery removeObjectForKey:[NSString stringWithFormat:@"%@1", kSwipesParamTag]];
            
            // update
            [self doUpdateToDo:todo query:mQuery];
        }
        return YES;
    }
    return NO;
}

- (BOOL)handleUpdateToDo:(NSDictionary *)query
{
    NSString* oldTitle = query[kSwipesParamOldTitle];
    if (nil != oldTitle) {
        NSArray* todos = [KPToDo findByTitle:oldTitle];
        if (nil != todos) {
            KPToDo* todo = todos[0];

            // update the title
            NSString* title = query[kSwipesParamTitle];
            if (nil != title) {
                todo.title = title;
            }
            
            [self doUpdateToDo:todo query:query];
        }
        return YES;
    }
    return NO;
}

- (BOOL)handleDeleteToDo:(NSDictionary *)query
{
    NSString* title = query[kSwipesParamTitle];
    if (nil != title) {
        NSArray* todos = [KPToDo findByTitle:title];
        if (nil != todos) {
            [KPToDo deleteToDos:todos save:YES force:NO];
        }
        return YES;
    }
    return NO;
}

#pragma mark - Tags

- (BOOL)handleAddTag:(NSDictionary *)query
{
    NSString* title = query[kSwipesParamTitle];
    if (nil != title) {
        NSArray* tags = [KPTag findByTitle:title];
        if (nil == tags) {
            [KPTag addTagWithString:title save:YES];
        }
        return YES;
    }
    return NO;
}

- (BOOL)handleUpdateTag:(NSDictionary *)query
{
    NSString* oldTitle = query[kSwipesParamOldTitle];
    if (nil != oldTitle) {
        NSArray* tags = [KPTag findByTitle:oldTitle];
        if (nil != tags) {
            KPTag* tag = tags[0];
            
            // update the title
            NSString* title = query[kSwipesParamTitle];
            if (nil != title) {
                tag.title = title;
                [KPCORE saveContextForSynchronization:nil];
            }
        }
        return YES;
    }
    return NO;
}

- (BOOL)handleDeleteTag:(NSDictionary *)query
{
    NSString* title = query[kSwipesParamTitle];
    if (nil != title) {
        NSArray* tags = [KPTag findByTitle:title];
        if (nil != tags) {
            for (KPTag* tag in tags) {
                [KPTag deleteTagWithString:tag.title save:YES];
            }
        }
        return YES;
    }
    return NO;
}

#pragma mark - Evernote

- (void)doCreateEvernote:(NSDictionary *)query guid:(NSString *)guid
{
    // FIXME search for such a note?
    [[EvernoteIntegration sharedInstance] fetchNoteWithGuid:guid block:^(EDAMNote *note, NSError *error) {
        if (error) {
            [UtilityClass sendError:error type:@"Evernote URL error"];
        }
        else {
            NSArray* todos = [KPToDo findByTitle:note.title];
            if (nil == todos) {
                KPToDo* todo = [KPToDo addItem:note.title priority:NO tags:[self arrayFromQuery:query withPrefix:kSwipesParamTag] save:NO];
                
                // remove tags
                NSMutableDictionary* mQuery = query.mutableCopy;
                [mQuery removeObjectForKey:[NSString stringWithFormat:@"%@1", kSwipesParamTag]];
                
                // attach evernote
                [todo attachService:EVERNOTE_SERVICE title:note.title identifier:guid sync:YES];
                
                // update
                [self doUpdateToDo:todo query:mQuery];
            }
        }
    }];
}

- (BOOL)handleAddEvernote:(NSDictionary *)query
{
    __block NSString* guid = query[kSwipesParamGiud];
    if (nil != guid) {
        if (![EvernoteIntegration sharedInstance].isAuthenticated) {
            [[EvernoteIntegration sharedInstance] authenticateEvernoteInViewController:ROOT_CONTROLLER withBlock:^(NSError *error) {
                if (!error) {
                    [self doCreateEvernote:query guid:guid];
                }
                else {
                    [UtilityClass sendError:error type:@"Evernote Auth error"];
                }
            }];
        }
        else {
            [self doCreateEvernote:query guid:guid];
        }
        return YES;
    }
    return NO;
}



@end
