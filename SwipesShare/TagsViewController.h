//
//  TagsViewController.h
//  Swipes
//
//  Created by demosten on 3/31/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KPTagList.h"

@interface TagsViewController : UIViewController

@property (nonatomic, weak) IBOutlet KPTagList* tagList;
@property (nonatomic, strong) NSArray* selectedTags;

@end
