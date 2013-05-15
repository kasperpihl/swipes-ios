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
#define CLEAR [UIColor clearColor]


#define TAG_HEIGHT 44
#define DEFAULT_SPACING 5
#define BUTTON_HEIGHT 44

#define TEXT_FIELD_FONT [UIFont fontWithName:@"HelveticaNeue-Light" size:18]
#define BUTTON_FONT [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:20]

#define TEXT_FIELD_CONTAINER_HEIGHT 50
#define COLOR_SEPERATOR_HEIGHT 5

#define TEXT_FIELD_MARGIN_LEFT 10
#define TEXT_FIELD_MARGIN_TOP 12
#define TEXT_FIELD_HEIGHT 30
#define SEPERATOR_WIDTH 1

#define SEGMENT_BACKGROUND [UIColor colorWithRed:           128.0/255.0 green:  128.0/255.0 blue:   128.0/255.0 alpha:1.0]
#define SEGMENT_SELECTED [UIColor colorWithRed:             70.0/255.0 green:   70.0/255.0 blue:    70.0/255.0 alpha:1.0]
#define NAVBAR_BACKROUND [UIColor colorWithRed:             168.0/255.0 green:  168.0/255.0 blue:   168.0/255.0 alpha:1.0]
#define TABLE_VIEW_BACKGROUND [UIColor colorWithRed:        230.0/255.0 green:  230.0/255.0 blue:   230.0/255.0 alpha:1.0]


#define SWIPES_BLUE [UIColor colorWithRed:                  57.0/255.0 green:   156.0/255.0 blue:   217.0/255.0 alpha:1.0]
#define DONE_COLOR [UIColor colorWithRed:                   180.0/255.0 green:  223.0/255.0 blue:   93.0/255.0 alpha:1.0]
#define SCHEDULE_COLOR [UIColor colorWithRed:               252.0/255.0 green:  128.0/255.0 blue:   109.0/255.0 alpha:1.0]


//#define TABLE_VIEW_BACKGROUND [UIColor colorWithRed:        77.0/255.0 green:   77.0/255.0 blue:    77.0/255.0 alpha:1.0]
//#define TABLE_VIEW_LIGHT_BACKGROUND [UIColor colorWithRed:  230.0/255.0 green:  230.0/255.0 blue:   230.0/255.0 alpha:1.0]
#define GRAY_SEPERATOR_COLOR [UIColor colorWithRed:         102.0/255.0 green:  102.0/255.0 blue:   102.0/255.0 alpha:1.0]
#define SCHEDULE_BUTTON_COLOR [UIColor colorWithRed:        237.0/255.0 green:  237.0/255.0 blue:   237.0/255.0 alpha:1.0]
#define BAR_BOTTOM_BACKGROUND_COLOR [UIColor colorWithRed:  51.0/255.0 green:   51.0/255.0 blue:    51.0/255.0 alpha:1.0]
#define POPUP_OVERLAY_COLOR [UIColor colorWithRed:          155.0/255.0 green:  155.0/255.0 blue:   155.0/255.0 alpha:0.5]
#define ALERT_BOX_BACKGROUND [UIColor colorWithRed:         37.0/255.0 green:   37.0/255.0 blue:    37.0/255.0 alpha:1.0]

#define BUTTON_COLOR [UIColor whiteColor]
#define TITLE_LABEL_COLOR [UtilityClass colorWithRed:102 green:102 blue:102 alpha:1]


#define notify(notifcation,selectr) [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectr) name:notifcation object:nil]
#define clearNotify() [[NSNotificationCenter defaultCenter] removeObserver:self]
#define kv(obj,key) [obj objectForKey:key]
#define CGRectSetPos( r, x, y ) CGRectMake( x, y, r.size.width, r.size.height )
#define CGRectSetX( r, x ) r = CGRectMake( x, r.origin.y, r.size.width, r.size.height )
#define CGRectSetY( r, y ) r = CGRectMake( r.origin.x, y, r.size.width, r.size.height )
#define CGRectSetSize( r, w, h ) r = CGRectMake( r.origin.x, r.origin.y, w, h )
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