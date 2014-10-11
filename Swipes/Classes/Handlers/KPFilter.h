//
//  KPFilter.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 11/10/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>
#define kFilter [KPFilter sharedInstance]
@class KPFilter;
@protocol KPFilterDelegate <NSObject>
-(void)didUpdateFilter:(KPFilter*)filter;
@end

@interface KPFilter : NSObject
@property (nonatomic, readonly) BOOL isActive;
@property (nonatomic, strong) NSMutableArray *selectedTags;
@property (nonatomic, strong, readonly) NSString *searchString;
@property (nonatomic, weak) NSObject<KPFilterDelegate> *delegate;
+(KPFilter*)sharedInstance;
-(void)selectTag:(NSString*)tag;
-(void)deselectTag:(NSString*)tag;
-(void)searchForString:(NSString*)string;

-(void)clearAll;
-(NSString*)readableFilter;
@end
