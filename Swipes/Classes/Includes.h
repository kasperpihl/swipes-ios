//
//  Includes.h
//  Shery
//
//  Created by Kasper Pihl Tornøe on 09/03/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

typedef enum {
    FBReturnTypeNeedPermissions = 0,
    FBReturnTypeCancelled,
    FBReturnTypeError,
    FBReturnTypeSuccess
} FBReturnType;
typedef enum {
    KPDLResultDownloading,
    KPDLResultError,
    KPDLResultSuccess
} KPDLResult;
typedef NS_ENUM(NSUInteger, KPControlCurrentState){
    KPControlCurrentStateAdd,
    KPControlCurrentStateEdit
};
typedef NS_ENUM(NSUInteger, KPSegmentButtons) {
    KPSegmentButtonSchedule,
    KPSegmentButtonToday,
    KPSegmentButtonDone
};
typedef NS_ENUM(NSUInteger, MCSwipeTableViewCellActivatedDirection) {
    MCSwipeTableViewCellActivatedDirectionBoth = 0,
    MCSwipeTableViewCellActivatedDirectionLeft,
    MCSwipeTableViewCellActivatedDirectionRight,
    MCSwipeTableViewCellActivatedDirectionNone
};
typedef NS_ENUM(NSUInteger, MCSwipeTableViewCellState){
    MCSwipeTableViewCellStateNone = 0,
    MCSwipeTableViewCellState1 = 1,
    MCSwipeTableViewCellState2 = 2,
    MCSwipeTableViewCellState3 = -1,
    MCSwipeTableViewCellState4 = -2
};
typedef NS_ENUM(NSUInteger, CellType) {
    CellTypeNone = 0,
    CellTypeSchedule,
    CellTypeToday,
    CellTypeDone
};
/* Insert below in pods target if it is logs */
NS_INLINE void mainBlock(void (^block)(void))
{
    if(dispatch_get_current_queue() == dispatch_get_main_queue()){
        block();
    }
    else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

#define SWIPES_BLUE [UIColor colorWithRed:47.0 / 255.0 green:141.0 / 255.0 blue:211.0 / 255.0 alpha:1.0]
#define DONE_COLOR [UIColor colorWithRed:85.0 / 255.0 green:213.0 / 255.0 blue:80.0 / 255.0 alpha:1.0]
#define SCHEDULE_COLOR [UIColor colorWithRed:254.0 / 255.0 green:217.0 / 255.0 blue:56.0 / 255.0 alpha:1.0]

#define notify(notifcation,selectr) [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectr) name:notifcation object:nil]
#define clearNotify() [[NSNotificationCenter defaultCenter] removeObserver:self]
#define kv(obj,key) [obj objectForKey:key]
#define CGRectSetPos( r, x, y ) CGRectMake( x, y, r.size.width, r.size.height )
#define CGRectSetX( r, x ) r = CGRectMake( x, r.origin.y, r.size.width, r.size.height )
#define CGRectSetY( r, y ) r = CGRectMake( r.origin.x, y, r.size.width, r.size.height )
#define parseFileCachePath(name) [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingFormat:@"/Parse/PFFileCache/%@",name]
typedef void (^ResultBlock)(id result, NSError *error);
typedef void (^ImageBlock)(UIImage *image, NSError *error);
typedef void (^DataBlock)(KPDLResult result, NSData *data, NSError* error);
typedef void (^NumberBlock) (NSInteger number, NSError *error);
typedef void (^ArrayBlock)(NSArray *objects, NSError *error);
typedef void (^SuccessfulBlock)(BOOL succeeded, NSError *error);
typedef BOOL (^FacebookRequestBlock)(FBReturnType status, id result, NSError *error);
typedef void (^FBReqIndexBlock)(FBReturnType status, NSInteger index, id result, NSError *error);

#define FACEBOOK_READ_PERMISSIONS [NSArray arrayWithObjects:@"user_birthday",@"email", nil]
#define FACEBOOK_WRITE_PERMISSIONS [NSArray arrayWithObjects:@"publish_stream", nil]
#define FB_ERROR_CODE [error.userInfo[FBErrorParsedJSONResponseKey][@"body"][@"error"][@"code"] integerValue]
#define FB_ERROR_MESSAGE error.userInfo[FBErrorParsedJSONResponseKey][@"body"][@"error"][@"message"]