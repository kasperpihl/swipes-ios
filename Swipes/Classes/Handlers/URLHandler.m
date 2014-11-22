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
// swipes://todo/add?title=test&schedule=now&subtask1=First%20task&subtask2=Second%20task
// swipes://todo/clean_add?title=test&schedule=now&subtask1=First%20task&subtask2=Second%20task
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

NSString* const kSwipesCommandAdd = @"/add";
NSString* const kSwipesCommandCleanAdd = @"/clean_add";
NSString* const kSwipesCommandUpdate = @"/update";
NSString* const kSwipesCommandDelete = @"/delete";
NSString* const kSwipesCommandView = @"/view";
NSString* const kSwipesCommandAddPrompt = @"/addprompt";

NSString* const kSwipesParamTitle = @"title";
NSString* const kSwipesParamOldTitle = @"oldtitle";
NSString* const kSwipesParamTag = @"tag";
NSString* const kSwipesParamPriority = @"priority";
NSString* const kSwipesParamNotes = @"notes";
NSString* const kSwipesParamSchedule = @"schedule";
NSString* const kSwipesParamSubtask = @"subtask";
NSString* const kSwipesParamId = @"id";

// x-callback-url support constants
NSString* const kXCallbackURLXSuccess = @"x-success";
NSString* const kXCallbackURLXError = @"x-error";
NSString* const kXCallbackURLErrorMessage = @"errorMessage";
NSString* const kXCallbackURLErrorCode = @"errorCode";

// errors
NSString* const kErrorMissingMandatoryParam = @"missing mandatory param";
NSString* const kErrorNoSuchTodo = @"no such task";
NSString* const kErrorTodoExists = @"task already exists";
NSString* const kErrorNoSuchTag = @"no such tag";
NSString* const kErrorTagExists = @"tag already exists";
NSString* const kErrorEvernoteAuthentication = @"not authenticated to evernote";

static NSDictionary* kErrorCodes;

@implementation URLHandler

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
        kErrorCodes = @{
                        kErrorMissingMandatoryParam: @(1),
                        kErrorNoSuchTodo: @(101),
                        kErrorTodoExists: @(102),
                        kErrorNoSuchTag: @(201),
                        kErrorTagExists: @(202),
                        kErrorEvernoteAuthentication: @(301),
                        };
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
                    return [self handleDeleteToDo:query updateXCallbackURL:YES];
                }
                else if ([url.path isEqualToString:kSwipesCommandCleanAdd]) {
                    return [self handleCleanAddToDo:query];
                }
                else if ([url.path isEqualToString:kSwipesCommandView]) {
                    return [self handleViewToDo:query];
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
        }
        else if ([url.host isEqualToString:kSwipesDomainToDo] && [url.path isEqualToString:kSwipesCommandAddPrompt]) {
            return [self handleAddPromptToDo:query];
        }
    }
    return NO;
}

- (NSArray *)arrayFromQuery:(NSDictionary *)query withPrefix:(NSString *)prefix
{
    // try adding 's' to the prefix
    NSMutableArray* result = [NSMutableArray array];
    NSString* firstQuery = query[[NSString stringWithFormat:@"%@s", prefix]];
    if (firstQuery == (id)[NSNull null]) {
        return result;
    }
    else if (firstQuery) {
        NSArray* components = [firstQuery componentsSeparatedByString:@","];
        for (NSString* item in components) {
            [result addObject:[item stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        }
    }
    
    // try enumerating numbers with prefix
    firstQuery = query[[NSString stringWithFormat:@"%@1", prefix]];
    if (firstQuery == (id)[NSNull null]) {
        return result;
    }
    if (nil != firstQuery) {
        for (NSUInteger i = 1; i < 255; i++) {
            NSString* data = query[[NSString stringWithFormat:@"%@%lu", prefix, (unsigned long)i]];
            if ((nil != data) && ((id)[NSNull null] != data)) {
                [result addObject:data];
            }
            else {
                break;
            }
        }
        return result;
    }
    return result.count ? result : nil;
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

- (BOOL)addTagIfNeeded:(NSString *)title
{
    NSArray* tags = [KPTag findByTitle:title];
    if (nil == tags) {
        [KPTag addTagWithString:title save:YES from:@"URL Scheme"];
    }
    return (nil == tags);
}

- (void)addTagsIfNeeded:(NSArray *)tags
{
    for (NSString* tagTitle in tags) {
        [self addTagIfNeeded:tagTitle];
    }
}

#pragma mark - x-callback-url

- (void)handleXCallbackURL:(NSDictionary *)query errorMessage:(NSString *)errorMessage errorCode:(NSNumber *)errorCode
{
    if (!errorMessage) {
        // we have success
        NSString* successString = query[kXCallbackURLXSuccess];
        if (successString) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:successString]];
        }
    }
    else {
        // we have an error
        NSString* errorString = query[kXCallbackURLXError];
        if (errorString) {
            NSURL* errorURL = [NSURL URLWithString:errorString];
            NSMutableString* finalString = errorString.mutableCopy;
            if (errorURL.query) {
                [finalString appendString:@"&"];
            }
            else {
                [finalString appendString:@"?"];
            }
            [finalString appendFormat:@"errorCode=%@&errorMessage=%@", errorCode, [errorMessage stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:finalString]];
        }
    }
}

- (void)handleXCallbackURL:(NSDictionary *)query errorMessage:(NSString *)errorMessage
{
    [self handleXCallbackURL:query errorMessage:errorMessage errorCode:kErrorCodes[errorMessage]];
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
    if (tags) {
        [self addTagsIfNeeded:tags];
        [todo setTags:[NSSet setWithArray:tags]];
    }
    
    NSArray* subtasks = [self arrayFromQuery:query withPrefix:kSwipesParamSubtask];
    if (subtasks) {
        for (NSString *subtaskTitle in subtasks) {
            [todo addSubtask:subtaskTitle save:NO from:@"URL Scheme"];
        }
    }
    
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
            NSArray* tags = [self arrayFromQuery:query withPrefix:kSwipesParamTag];
            [self addTagsIfNeeded:tags];
            KPToDo* todo = [KPToDo addItem:title priority:NO tags:tags save:NO from:@"URL Scheme"];
            
            // remove tags
            NSMutableDictionary* mQuery = query.mutableCopy;
            [mQuery removeObjectForKey:[NSString stringWithFormat:@"%@1", kSwipesParamTag]];
            [mQuery removeObjectForKey:[NSString stringWithFormat:@"%@s", kSwipesParamTag]];
            
            // update
            [self doUpdateToDo:todo query:mQuery];
            [self handleXCallbackURL:query errorMessage:nil];
        }
        else {
            [self handleXCallbackURL:query errorMessage:kErrorTodoExists];
        }
        return YES;
    }
    else {
        [self handleXCallbackURL:query errorMessage:kErrorMissingMandatoryParam];
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
            [self handleXCallbackURL:query errorMessage:nil];
        }
        else {
            [self handleXCallbackURL:query errorMessage:kErrorNoSuchTodo];
        }
        return YES;
    }
    else {
        [self handleXCallbackURL:query errorMessage:kErrorMissingMandatoryParam];
    }
    return NO;
}

- (BOOL)handleDeleteToDo:(NSDictionary *)query updateXCallbackURL:(BOOL)updateXCallbackURL
{
    NSString* title = query[kSwipesParamTitle];
    if (nil != title) {
        NSArray* todos = [KPToDo findByTitle:title];
        if (nil != todos) {
            [KPToDo deleteToDos:todos save:YES force:NO];
            if (updateXCallbackURL)
                [self handleXCallbackURL:query errorMessage:nil];
        }
        else if (updateXCallbackURL) {
            [self handleXCallbackURL:query errorMessage:kErrorNoSuchTodo];
        }
        return YES;
    }
    else if (updateXCallbackURL) {
        [self handleXCallbackURL:query errorMessage:kErrorMissingMandatoryParam];
    }
    return NO;
}

- (BOOL)handleCleanAddToDo:(NSDictionary *)query
{
    [self handleDeleteToDo:query updateXCallbackURL:NO];
    return [self handleAddToDo:query];
}

- (BOOL)handleViewToDo:(NSDictionary *)query
{
    NSString* tempId = query[kSwipesParamId];
    if (nil != tempId) {
        NSArray* todos = [KPToDo findByTempId:tempId];
        if (nil != todos) {
            self.viewTodo = todos[0];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"handled URL" object:self];
            [self handleXCallbackURL:query errorMessage:nil];
        }
        else {
            [self handleXCallbackURL:query errorMessage:kErrorNoSuchTodo];
        }
        return YES;
    }
    else {
        // Kasper: I added this to make a way to reset upon opening, using /view without parameters
        self.reset = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"handled URL" object:self];
        [self handleXCallbackURL:query errorMessage:kErrorMissingMandatoryParam];
    }
    return NO;
}

- (BOOL)handleAddPromptToDo:(NSDictionary *)query
{
    self.addTodo = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"handled URL" object:self];
    [self handleXCallbackURL:query errorMessage:nil];
    return YES;
}

#pragma mark - Tags

- (BOOL)handleAddTag:(NSDictionary *)query
{
    NSString* title = query[kSwipesParamTitle];
    if (nil != title) {
        if ([self addTagIfNeeded:title]) {
            [self handleXCallbackURL:query errorMessage:nil];
        }
        else {
            [self handleXCallbackURL:query errorMessage:kErrorTagExists];
        }
        return YES;
    }
    else {
        [self handleXCallbackURL:query errorMessage:kErrorMissingMandatoryParam];
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
                [self handleXCallbackURL:query errorMessage:nil];
            }
            else {
                [self handleXCallbackURL:query errorMessage:kErrorMissingMandatoryParam];
            }
        }
        else {
            [self handleXCallbackURL:query errorMessage:kErrorNoSuchTag];
        }
        return YES;
    }
    else {
        [self handleXCallbackURL:query errorMessage:kErrorMissingMandatoryParam];
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
        else {
            [self handleXCallbackURL:query errorMessage:kErrorNoSuchTag];
        }
        return YES;
    }
    else {
        [self handleXCallbackURL:query errorMessage:kErrorMissingMandatoryParam];
    }
    return NO;
}

@end
