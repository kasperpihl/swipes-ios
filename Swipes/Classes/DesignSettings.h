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
#define GLOBAL_TOOLBAR_HEIGHT           50.0f
#define GLOBAL_ANIMATION_DURATION       0.15f
#define GLOBAL_TEXTFIELD_HEIGHT         70.0f
#define GLOBAL_DOT_SIZE                 12.0f
#define GLOBAL_DOT_OUTLINE_SIZE         4.0f
#define GLOBAL_CELL_HEIGHT              70.0f
#define KEYBOARD_HEIGHT                 216.0f
#define KEYBOARD_ANIMATION_DURATION     0.25f
#define GLOBAL_WT_TABLE_WIDTH           235.0f


#define KP_LIGHT(fontSize)              [UIFont fontWithName:@"ProximaNova-Light" size:fontSize]
#define KP_BLACK(fontSize)              [UIFont fontWithName:@"ProximaNova-Black" size:fontSize]
#define KP_REGULAR(fontSize)            [UIFont fontWithName:@"ProximaNova-Regular" size:fontSize]
#define KP_BOLD(fontSize)               [UIFont fontWithName:@"ProximaNova-Bold" size:fontSize]
#define KP_SEMIBOLD(fontSize)           [UIFont fontWithName:@"ProximaNova-Semibold" size:fontSize]
#define KP_COND_BOLD(fontSize)          [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:fontSize]
#define KP_COND_SEMIBOLD(fontSize)      [UIFont fontWithName:@"ProximaNovaCond-Semibold" size:fontSize]

#define SCHEDULE_BUTTON_FONT            KP_SEMIBOLD(14)
#define SCHEDULE_BUTTON_CAPITAL         NO

#define MIN_SEARCH_LETTER_LENGTH        1
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
#define TABLE_EMPTY_BG_TEXT_HEIGHT      40
#define CELL_ALARM_FONT                 KP_REGULAR(14)

/* Edit Task view */
#define EDIT_TASK_TITLE_FONT            KP_LIGHT(18)
#define EDIT_TASK_TEXT_FONT             KP_REGULAR(14)
#define EDIT_TASK_TEXT_COLOR            BUTTON_COLOR
#define EDIT_TASK_GRAYED_OUT_TEXT       gray(180,1)//EDIT_TASK_SEPERATOR_COLOR
#define EDIT_TASK_SELECTED_OVERLAY      

/* Login View */


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
#define LOGIN_FIELDS_FONT               KP_LIGHT(14)
#define LOGIN_LABEL_ABOVE_FONT          KP_LIGHT(13)
#define LOGIN_FIELDS_TEXT_COLOR         color(187,195,203,1)


/* Add tag panel */
#define MANAGE_TAGS_BACKGROUND          TEXTFIELD_BACKGROUND


/* KPPopup */

/* SchedulePopup */
#define POPUP_BACKGROUND                color(30,34,40,.9)
#define POPUP_SELECTED                  gray(218,1)


#define TAG_HEIGHT 38
#define DEFAULT_SPACING 5
#define BUTTON_HEIGHT 44
#define SEARCH_BAR_DEFAULT_HEIGHT 55

#define DEFAULT_SPACE_FROM_SLIDE_UP_VIEW 60


#define BUTTON_FONT                     KP_COND_BOLD(20)
#define TAGS_LABEL_BOLD_FONT            KP_BOLD(12)
#define TABLE_EMPTY_BG_FONT             KP_REGULAR(20)
#define NO_TAG_FONT                     KP_LIGHT(18)
#define TEXT_FIELD_FONT                 KP_LIGHT(18)
#define SECTION_HEADER_FONT             KP_LIGHT(18)
#define TITLE_LABEL_FONT                KP_LIGHT(19)
#define TAGS_LABEL_FONT                 KP_LIGHT(13)
#define TAG_FONT                        KP_LIGHT(18)




#define TEXT_FIELD_CONTAINER_HEIGHT 50
#define COLOR_SEPERATOR_HEIGHT 3

#define TABLE_CELL_SEPERATOR_HEIGHT 1

#define TEXT_FIELD_MARGIN_LEFT 15

#define TEXT_FIELD_MARGIN_TOP 12
#define TEXT_FIELD_HEIGHT 30
#define SEPERATOR_WIDTH .5

#define SEGMENT_BUTTON_WIDTH 106
#define SEGMENT_BUTTON_HEIGHT 44

#define ALERT_BOX_BACKGROUND            gray(37,1)



