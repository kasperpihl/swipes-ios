//
//  DesignSettings.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 17/05/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//
/* Fonts
 "ProximaNova-Regular",
 "ProximaNova-Light",
 "ProximaNova-Black",
 "ProximaNova-Bold"
*/
#import "ThemeHandler.h"

/* GLOBALS */
#define kGAnanlytics [[GAI sharedInstance] defaultTracker]


#define LINE_SIZE                       1.0f
#define GLOBAL_TOOLBAR_HEIGHT           60.0f
#define GLOBAL_ANIMATION_DURATION       0.20f
#define GLOBAL_TEXTFIELD_HEIGHT         55.0f
#define GLOBAL_DOT_SIZE                 10.0f
#define GLOBAL_DOT_OUTLINE_SIZE         4.0f
#define GLOBAL_CELL_HEIGHT              70.0f
#define KEYBOARD_ANIMATION_DURATION     0.25f
#define GLOBAL_WT_TABLE_WIDTH           232.0f
#define CELL_LABEL_X 44

#define KP_FONT(fontName, fontSize) [UIFont fontWithName:fontName size:fontSize * [Global sharedInstance].fontMultiplier]

#define KP_LIGHT(fontSize)              KP_FONT(@"GothamRounded-Light",fontSize)
#define KP_REGULAR(fontSize)            KP_FONT(@"GothamRounded-Book", fontSize)//[UIFont fontWithName:@"VarelaRound-Regular" size:fontSize]
#define KP_BOLD(fontSize)               KP_FONT(@"GothamRounded-Bold",fontSize)
#define KP_SEMIBOLD(fontSize)           KP_FONT(@"GothamRounded-Medium", fontSize)


#define SCHEDULE_BUTTON_FONT            KP_REGULAR(12)
#define SCHEDULE_BUTTON_CAPITAL         NO

#define MIN_SEARCH_LETTER_LENGTH        3
#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

//RGB color macro with alpha
#define UIColorFromRGBWithAlpha(rgbValue,a) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]



/* Text Colors */


/* Table View */
#define TABLE_EMPTY_BG_TEXT_HEIGHT      20
#define CELL_ALARM_FONT                 KP_REGULAR(11)

/* Edit Task view */
#define EDIT_TASK_TITLE_FONT            KP_LIGHT(18)
#define EDIT_TASK_TEXT_FONT             KP_REGULAR(14)


/* Walk through */
#define WALKTHROUGH_BACKGROUND          color(117,122,130,1)
#define WALKTHROUGH_DESCRIPTION_FONT    KP_LIGHT(17)
#define WALKTHROUGH_DESCRIPTION_COLOR   BUTTON_COLOR
#define WALKTHROUGH_TITLE_FONT          KP_REGULAR(20)
#define WALKTHROUGH_TITLE_BACKGROUND    color(177,180,185,1)
#define WALKTHROUGH_TITLE_COLOR         gray(249,1)


#define SIGNUP_BUTTON_BACKGROUND        DONE_COLOR
#define LOGIN_FIELDS_BACKGROUND         color(97,105,113,1)
#define LOGIN_FIELDS_SEPERATOR_COLOR    color(187,195,203,1)
#define SIGNUP_BUTTON_FONT              KP_LIGHT(18)
#define LOGIN_FIELDS_FONT               KP_REGULAR(14)
#define LOGIN_LABEL_ABOVE_FONT          KP_LIGHT(13)
#define LOGIN_FIELDS_TEXT_COLOR         color(187,195,203,1)




/* KPPopup */

/* SchedulePopup */
#define POPUP_BACKGROUND                color(30,34,40,.9)
#define POPUP_SELECTED                  gray(218,1)


#define TAG_HEIGHT 32
#define DEFAULT_SPACING 5
#define BUTTON_HEIGHT 44
#define SEARCH_BAR_DEFAULT_HEIGHT 55

#define DEFAULT_SPACE_FROM_SLIDE_UP_VIEW 60


#define TAGS_LABEL_BOLD_FONT            KP_BOLD(11)
#define TABLE_EMPTY_BG_FONT             KP_REGULAR(16)
#define NO_TAG_FONT                     KP_REGULAR(16)
#define TEXT_FIELD_FONT                 KP_LIGHT(18)
#define NOTES_VIEW_FONT                 KP_REGULAR(17)
#define SECTION_HEADER_FONT             KP_REGULAR(11)
#define TITLE_LABEL_FONT                KP_REGULAR(16)
#define TAGS_LABEL_FONT                 KP_REGULAR(11)
#define TAG_FONT                        KP_LIGHT(18)




#define TEXT_FIELD_CONTAINER_HEIGHT 50
#define COLOR_SEPERATOR_HEIGHT 3

#define TABLE_CELL_SEPERATOR_HEIGHT 1

#define TEXT_FIELD_MARGIN_LEFT 15

#define TEXT_FIELD_MARGIN_TOP 12
#define TEXT_FIELD_HEIGHT 30
#define SEPERATOR_WIDTH .5

//70//80//106
//#define SEGMENT_BUTTON_HEIGHT 44

#define ALERT_BOX_BACKGROUND            gray(37,1)


#define kWalkthroughBackground              gray(255,1)
#define kWalkthroughUnselectedTextColor     gray(204,1)
#define kWalkthroughSelectedTextColor       gray(128,1)
#define kWalkthroughUnselectedBackground    gray(235,1)
#define W_CELL                  gray(230,1)

#define W_TIMELINE_ACTIVATED    gray(128,1)
#define W_CELL_ACTIVATED        tcolor(BackgroundColor)

#define W_TITLE_ACTIVATED       gray(255,1)


