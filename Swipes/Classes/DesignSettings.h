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
#define retColor(DarkColor,LightColor) ((THEMER.currentTheme == ThemeDark) ? DarkColor : LightColor)
#define inv(color) [ThemeHandler inverseColor:color]
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

/* Main colors */
#define TASKS_COLOR                     retColor(color(244,219,39,1),color(244,219,39,1))
#define DONE_COLOR                      retColor(color(63,186,141,1),color(63,186,141,1))
#define LATER_COLOR                     retColor(color(253,99,73,1),color(253,99,73,1))


#define MENU_BACKGROUND                 retColor(color(44,50,59,1),inv(color(44,50,59,1)))
#define MENU_SELECTED_BACKGROUND        retColor(color(86,91,98,1),inv(color(86,91,98,1)))
#define TASK_CELL_BACKGROUND            retColor(color(98,105,114,1),inv(color(98,105,114,1)))
#define TASK_TABLE_SECTION_BACKGROUND   retColor(color(65,68,74,1),inv(color(65,68,74,1)))

#define CELL_TITLE_COLOR                retColor(color(176,179,184,1),inv(color(176,179,184,1)))
#define TEXTFIELD_BACKGROUND            retColor(inv(color(25,29,35,1)),color(25,29,35,1)) // Background for text field ie. the drawer

/* Text Colors */
#define TEXT_FIELD_COLOR                retColor(gray(230,1),inv(gray(230,1)))
#define TITLE_LABEL_COLOR               retColor(gray(102,1),inv(gray(102,1)))
#define BUTTON_COLOR                    gray(255,1)

#define CELL_TAG_COLOR                  TEXT_FIELD_COLOR


/* Table View */
#define CELL_TIMELINE_COLOR             TABLE_CELL_SEPERATOR_COLOR//color(189,189,190,1)
#define TABLE_EMPTY_BG_TEXT_HEIGHT      40
#define TABLE_CELL_SELECTED_BACKGROUND  CELL_TIMELINE_COLOR
#define CELL_ALARM_TEXT_COLOR           CELL_TITLE_COLOR
#define CELL_ALARM_FONT                 KP_REGULAR(14)

/* Edit Task view */
#define EDIT_TASK_TITLE_FONT            KP_LIGHT(19)
#define EDIT_TASK_TEXT_FONT             KP_LIGHT(16)
#define EDIT_TASK_TITLE_COLOR           CELL_TITLE_COLOR
#define EDIT_TASK_TEXT_COLOR            BUTTON_COLOR
#define EDIT_TASK_GRAYED_OUT_TEXT       gray(180,1)//EDIT_TASK_SEPERATOR_COLOR
#define EDIT_TASK_SELECTED_OVERLAY      

/* Login View */
#define LOGIN_LOGO_Y            0
#define LOGIN_FIELDS_Y          50
#define FIELDS_WIDTH            260
#define SIGNUP_BUTTONS_HEIGHT   50

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

#define DOT_SIZE 12

#define TAG_HEIGHT 44
#define DEFAULT_SPACING 5
#define BUTTON_HEIGHT 44
#define SEARCH_BAR_DEFAULT_HEIGHT 55

#define DEFAULT_SPACE_FROM_SLIDE_UP_VIEW 60
#define KEYBOARD_HEIGHT 216


#define BUTTON_FONT                     KP_COND_BOLD(20)
#define TAGS_LABEL_BOLD_FONT            KP_BOLD(12)
#define TABLE_EMPTY_BG_FONT             KP_LIGHT(20)
#define NO_TAG_FONT                     KP_LIGHT(18)
#define TEXT_FIELD_FONT                 KP_LIGHT(18)
#define SECTION_HEADER_FONT             KP_LIGHT(18)
#define TITLE_LABEL_FONT                KP_LIGHT(19)
#define TAGS_LABEL_FONT                 KP_LIGHT(13)
#define TAG_FONT                        KP_REGULAR(17)




#define TEXT_FIELD_CONTAINER_HEIGHT 50
#define COLOR_SEPERATOR_HEIGHT 3

#define TABLE_CELL_SEPERATOR_HEIGHT 1

#define TEXT_FIELD_MARGIN_LEFT 10

#define TEXT_FIELD_MARGIN_TOP 12
#define TEXT_FIELD_HEIGHT 30
#define SEPERATOR_WIDTH .5

#define SEGMENT_BUTTON_WIDTH 106
#define SEGMENT_BUTTON_HEIGHT 44

#define ALERT_BOX_BACKGROUND            gray(37,1)



