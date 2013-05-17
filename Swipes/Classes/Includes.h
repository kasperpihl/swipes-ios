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
#define color(r,g,b,a) [UIColor colorWithRed: r/255.0 green: g/255.0 blue: b/255.0 alpha:a]
#define gray(l,a) [UIColor colorWithRed: l/255.0 green: l/255.0 blue: l/255.0 alpha:a]

#define TAG_HEIGHT 44
#define DEFAULT_SPACING 5
#define BUTTON_HEIGHT 44

#define TEXT_FIELD_FONT [UIFont fontWithName:@"HelveticaNeue-Light" size:18]
#define BUTTON_FONT [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:20]
#define SECTION_HEADER_FONT [UIFont fontWithName:@"HelveticaNeue-Light" size:18]

#define TEXT_FIELD_CONTAINER_HEIGHT 55
#define COLOR_SEPERATOR_HEIGHT 5

#define TABLE_CELL_SEPERATOR_HEIGHT 1

#define TEXT_FIELD_MARGIN_LEFT 10

#define TEXT_FIELD_MARGIN_TOP 12
#define TEXT_FIELD_HEIGHT 30
#define SEPERATOR_WIDTH .5

#define SEGMENT_BUTTON_WIDTH 106
#define SEGMENT_BUTTON_HEIGHT 44


#define SEGMENT_SELECTED                color(44,50,59,1)
#define NAVBAR_BACKROUND                gray(38,1)
#define SEGMENT_BACKGROUND              color(30,34,40,1) //gray(51,1)//NAVBAR_BACKROUND
#define TABLE_CELL_BACKGROUND           color(59,67,79,1)
#define TABLE_BACKGROUND                color(44,50,59,1) //TABLE_CELL_BACKGROUND
#define TEXTFIELD_BACKGROUND            color(25,29,35,1) //SEGMENT_BACKGROUND

#define TODAY_COLOR                     color(214,196,45,1)
#define DONE_COLOR                      color(63,186,141,1)
#define SCHEDULE_COLOR                  color(252,128,109,1)
#define SWIPES_BLUE                     TODAY_COLOR

// 
// Seperator :: gray(77,1)

#define SEGMENT_BORDER_COLOR            gray(61,1)
#define TABLE_CELL_SELECTED_BACKGROUND  SEGMENT_BACKGROUND
#define TAG_COLOR_BACKGROUND            SEGMENT_SELECTED
#define TABLE_CELL_SEPERATOR_COLOR      color(44,50,59,1)
#define SECTION_HEADER_BACKGROUND       SEGMENT_BACKGROUND

#define SECTION_HEADER_COLOR            color(98,105,114,1)
#define CELL_TITLE_COLOR                color(177,180,185,1)
#define CELL_TAG_COLOR                  gray(230,1)






#define BAR_BOTTOM_BACKGROUND_COLOR     gray(51,1)
#define POPUP_OVERLAY_COLOR             gray(155,0.5)
#define ALERT_BOX_BACKGROUND            gray(37,1)

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