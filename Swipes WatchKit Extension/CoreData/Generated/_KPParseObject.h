//
//  KPParseObject.h
//  Swipes
//
//  Created by demosten on 12/27/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface _KPParseObject : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSNumber * isLocallyDeleted;
@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSString * parseClassName;
@property (nonatomic, retain) NSString * tempId;
@property (nonatomic, retain) NSDate * updatedAt;

@end
