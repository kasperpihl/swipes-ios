//
//  DesignSettings.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 17/05/13.
//  Copyright (c) 2013 Pihl IT. All rights reserved.
//

#define MIN_SEARCH_LETTER_LENGTH 1

/* Main colors */
#define TODAY_COLOR                     color(214,196,45,1)//color(253,230,73,1)
#define DONE_COLOR                      color(63,186,141,1)
#define SCHEDULE_COLOR                  color(252,128,109,1)
#define SWIPES_COLOR                    TODAY_COLOR

/* Segmented controller  */
#define SEGMENT_BACKGROUND              color(30,34,40,1) // Color for segment button that is not selected
#define SEGMENT_SELECTED                color(44,50,59,1) // Color for selected segment
#define SEGMENT_BORDER_COLOR            SEGMENT_SELECTED//gray(61,1)        // Color for the border between segments
#define TEXTFIELD_BACKGROUND            color(25,29,35,1) // Background for text field ie. the drawer

/* Text Colors */
#define TEXT_FIELD_COLOR                gray(230,1)
#define TITLE_LABEL_COLOR               gray(102,1)
#define BUTTON_COLOR                    gray(255,1)
#define SECTION_HEADER_COLOR            color(98,105,114,1)
#define CELL_TITLE_COLOR                color(177,180,185,1)
#define CELL_TAG_COLOR                  TEXT_FIELD_COLOR


/* Table View */
#define TABLE_BACKGROUND                SEGMENT_BACKGROUND//color(44,50,59,1) // Background for the tableview's
#define TABLE_CELL_BACKGROUND           color(59,67,79,1) // Background for task table cells
#define TABLE_CELL_SEPERATOR_COLOR      SEGMENT_SELECTED // Seperator between task cells
#define CELL_TIMELINE_COLOR             TABLE_CELL_SEPERATOR_COLOR//color(189,189,190,1)
#define TABLE_EMPTY_BG_TEXT             TABLE_CELL_BACKGROUND
#define TABLE_EMPTY_BG_COLORED_TEXT     alpha(SWIPES_COLOR,.7)
#define TABLE_EMPTY_BG_TEXT_HEIGHT      40

#define SECTION_HEADER_BACKGROUND       SEGMENT_BACKGROUND
#define TABLE_CELL_SELECTED_BACKGROUND  CELL_TIMELINE_COLOR//color(45,51,60,1)//[TODOHANDLER colorForCellType:self.cellType]//SEGMENT_BACKGROUND
#define TABLE_CELL_SELECTED_TITLE_COLOR TABLE_CELL_BACKGROUND


/* Edit Task view */
#define EDIT_TASK_TITLE_COLOR           TEXT_FIELD_COLOR
#define EDIT_TASK_TITLE_BACKGROUND      SEGMENT_SELECTED
#define EDIT_TASK_BACKGROUND            TABLE_CELL_BACKGROUND//SEGMENT_BACKGROUND
#define EDIT_TASK_SEPERATOR_COLOR       SECTION_HEADER_COLOR
#define EDIT_TASK_TEXT_COLOR            BUTTON_COLOR
#define EDIT_TASK_GRAYED_OUT_TEXT       gray(180,1)//EDIT_TASK_SEPERATOR_COLOR
#define EDIT_TASK_SELECTED_OVERLAY      

/* Login View */
#define LOGIN_LOGO_Y        0
#define LOGIN_FIELDS_Y      50
#define FIELDS_WIDTH 260
#define SIGNUP_BUTTONS_HEIGHT 44

#define LOGIN_BUTTON_BACKGROUND         TABLE_CELL_BACKGROUND
#define SIGNUP_BUTTON_BACKGROUND        DONE_COLOR
#define LOGIN_FIELDS_BACKGROUND         color(97,105,113,1)
#define LOGIN_FIELDS_SEPERATOR_COLOR    color(187,195,203,1)
#define SIGNUP_BUTTON_FONT              [UIFont fontWithName:@"HelveticaNeue-Light" size:18]
#define LOGIN_FIELDS_FONT               [UIFont fontWithName:@"HelveticaNeue-Light" size:14]
#define LOGIN_LABEL_ABOVE_FONT          [UIFont fontWithName:@"HelveticaNeue-Light" size:12]
#define LOGIN_FIELDS_TEXT_COLOR         color(187,195,203,1)
#define LOGIN_LABEL_ABOVE_COLOR         SECTION_HEADER_COLOR//color(204,208,214,1)

#define TAG_COLOR_BACKGROUND            SEGMENT_SELECTED



/* Add tag panel */
#define MANAGE_TAGS_BACKGROUND          TEXTFIELD_BACKGROUND
#define ADD_TAG_SEPERATOR_COLOR         SWIPES_COLOR
#define BAR_BOTTOM_BACKGROUND_COLOR     SEGMENT_BACKGROUND
#define BAR_BOTTOM_BUTTON_SEPS          SEGMENT_SELECTED

/* KPPopup */
#define POPUP_OVERLAY_COLOR             gray(102,0.5)

/* SchedulePopup */
#define POPUP_BACKGROUND SEGMENT_BACKGROUND


#define DOT_SIZE 12

#define TAG_HEIGHT 44
#define DEFAULT_SPACING 5
#define BUTTON_HEIGHT 44
#define SEARCH_BAR_DEFAULT_HEIGHT 55

#define DEFAULT_SPACE_FROM_SLIDE_UP_VIEW 60
#define KEYBOARD_HEIGHT 216


#define BUTTON_FONT [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:20]

#define TAGS_LABEL_BOLD_FONT [UIFont fontWithName:@"HelveticaNeue-Bold" size:12]

#define TABLE_EMPTY_BG_FONT [UIFont fontWithName:@"HelveticaNeue-Light" size:20]


#define NO_TAG_FONT [UIFont fontWithName:@"HelveticaNeue-Light" size:18]
#define TEXT_FIELD_FONT [UIFont fontWithName:@"HelveticaNeue-Light" size:18]
#define SECTION_HEADER_FONT [UIFont fontWithName:@"HelveticaNeue-Light" size:18]
#define TITLE_LABEL_FONT [UIFont fontWithName:@"HelveticaNeue-Light" size:18]

#define TAGS_LABEL_FONT [UIFont fontWithName:@"HelveticaNeue-Light" size:12]


#define SCHEDULE_BUTTON_FONT [UIFont fontWithName:@"Franchise-Bold" size:20]


#define TAG_FONT [UIFont fontWithName:@"HelveticaNeue" size:16]









#define TEXT_FIELD_CONTAINER_HEIGHT 50
#define COLOR_SEPERATOR_HEIGHT 3

#define TABLE_CELL_SEPERATOR_HEIGHT 1

#define TEXT_FIELD_MARGIN_LEFT 10

#define TEXT_FIELD_MARGIN_TOP 12
#define TEXT_FIELD_HEIGHT 30
#define SEPERATOR_WIDTH .5

#define SEGMENT_BUTTON_WIDTH 106
#define SEGMENT_BUTTON_HEIGHT 44




//














#define ALERT_BOX_BACKGROUND            gray(37,1)



