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
typedef NS_ENUM(NSUInteger, KPCurrentMenu) {
    KPCurrentMenuSchedule,
    KPCurrentMenuToday,
    KPCurrentMenuDone
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
typedef enum {
    RepeatNever = 0,
    RepeatEveryDay,
    RepeatEveryMonFriOrSatSun,
    RepeatEveryWeek,
    RepeatEveryMonth,
    RepeatEveryYear,
    RepeatOptionsTotal
} RepeatOptions;

typedef enum {
    PositionCenter,
    PositionTop,
    PositionBottom
} DisplayPosition;

typedef void (^voidBlock)(void);
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
#define kCurrent [PFUser currentUser]
#define kCurrentAttr(attr) [kCurrent objectForKey:attr]
#define kCurrentSetAttr(key,attr) [kCurrent setObject:attr forKey:key]

#define sizeWithFont(string,font) ((OSVER >= 7) ? [string sizeWithAttributes:@{NSFontAttributeName:font}] : [string sizeWithFont:font])


#define radians(degrees) (degrees * M_PI / 180)
#define degrees(radians) (radians * 180 / M_PI)

#define kIsIphone5Size (fabs((double)[[UIScreen mainScreen] bounds].size.height - (double) 568) < DBL_EPSILON)
#define valForScreen(iphone4, iphone5) (kIsIphone5Size ? iphone5 : iphone4)

#define CLEAR [UIColor clearColor]
#define color(r,g,b,a) [UIColor colorWithRed: r/255.0 green: g/255.0 blue: b/255.0 alpha:a]
#define gray(l,a) [UIColor colorWithRed: l/255.0 green: l/255.0 blue: l/255.0 alpha:a]
#define alpha(c,a) [c colorWithAlphaComponent:a]
#define trim(s) [s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
#define CGRectSetPos( r, x, y ) CGRectMake( x, y, r.size.width, r.size.height )
#define centerItemForSize( item, containerWidth, containerHeight) item.frame = CGRectSetPos(item.frame,(containerWidth-item.frame.size.width)/2,(containerHeight-item.frame.size.height)/2)

#define notify(notifcation,selectr) [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectr) name:notifcation object:nil]
#define clearNotify() [[NSNotificationCenter defaultCenter] removeObserver:self]
#define kv(obj,key) [obj objectForKey:key]

#define CGRectSetCenter( r , x , y ) r.center = CGPointMake( x , y )
#define CGRectSetCenterX( r, x ) r.center = CGPointMake( x , r.center.y )
#define CGRectSetCenterY( r, y ) r.center = CGPointMake( r.center.x , y )

#define CGRectSetX( r, x ) r.frame = CGRectMake( x, r.frame.origin.y, r.frame.size.width, r.frame.size.height )
#define CGRectSetY( r, y ) r.frame = CGRectMake( r.frame.origin.x, y, r.frame.size.width, r.frame.size.height )
#define CGRectSetSize( r, w, h ) r.frame = CGRectMake( r.frame.origin.x, r.frame.origin.y, w, h )
#define CGRectSetWidth( r, w ) r.frame = CGRectMake( r.frame.origin.x, r.frame.origin.y, w, r.frame.size.height )
#define CGRectSetHeight( r, h ) r.frame = CGRectMake( r.frame.origin.x, r.frame.origin.y, r.frame.size.width, h )
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