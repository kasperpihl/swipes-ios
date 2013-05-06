//
//  CoreDataClass.m
//  Shery
//
//  Created by Kasper Pihl Tornøe on 09/03/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#import "KPParseCoreData.h"
#import "UtilityClass.h"
#import "ToDoHandler.h"
#import "TagHandler.h"
/*

*/
@interface KPParseCoreData ()
@property (nonatomic,assign) BOOL isPerformingOperation;
@property (nonatomic,assign) BOOL didLogout;
@property (nonatomic,strong) NSManagedObjectContext *context;
@end
@implementation KPParseCoreData
-(NSManagedObjectContext *)context{
    return [NSManagedObjectContext MR_defaultContext];
}
+(NSString *)classNameFromParseName:(NSString *)parseClassName{
    return [NSString stringWithFormat:@"KP%@",parseClassName];
}
#pragma mark Instantiation
static KPParseCoreData *sharedObject;
+(KPParseCoreData *)sharedInstance{
    if(!sharedObject){
        sharedObject = [[KPParseCoreData allocWithZone:NULL] init];
        [sharedObject initialize];
    }
    return sharedObject;
}
#pragma mark Core data stuff
-(void)initialize{
    [self loadDatabase];
    if(![UTILITY.userDefaults boolForKey:@"seeded"]){
        [self seedObjects];
    }
}
-(void)loadDatabase{
    NSLog(@"error here");
    //[MagicalRecord setupCoreDataStackWithInMemoryStore];
    @try {
        [MagicalRecord setupCoreDataStackWithStoreNamed:@"shery"];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    @finally {
        
    }
    
    NSLog(@"no here");
}

-(void)cleanUp{
    NSURL *storeURL = [NSPersistentStore MR_urlForStoreName:@"coredata.sqlite"];
    NSError *error;
    BOOL removed = [[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:&error];
    if(removed){
        [MagicalRecord cleanUp];
        [self loadDatabase];
    }
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}
-(void)dealloc{
    [MagicalRecord cleanUp];
}

-(void)seedObjects{
    NSArray *tagArray = @[
                        @"Home",
                        @"Guide",
                        @"Swipes",
                        @"Work"
    ];
    for(NSString *tag in tagArray){
        [TAGHANDLER addTag:tag];
    }
    NSArray *toDoArray = @[
                       @"Hold to drag me up and down",
                       @"Swipe left to schedule me",
                       @"Swipe right to complete me",
                       @"Assign us tags",
                       @"Select me too",
                       @"Tap to select me"
                       ];
    for(NSInteger i = 0 ; i < toDoArray.count ; i++){
        NSString *item = [toDoArray objectAtIndex:i];
        [TODOHANDLER addItem:item];
        
        if(i == 3) [TAGHANDLER addTags:@[@"Work",@"Swipes"] andRemoveTags:nil fromToDos:@[]];
    }
    
    NSArray *todosForTagsArray = [KPToDo MR_findAll];
    todosForTagsArray = [todosForTagsArray subarrayWithRange:NSMakeRange(0, 3)];
    [TAGHANDLER addTags:@[@"Guide",@"Swipes"] andRemoveTags:nil fromToDos:todosForTagsArray];
    [UTILITY.userDefaults setBool:YES forKey:@"seeded"];
}
@end
