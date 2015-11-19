//
//  SWAToDo.h
//  Swipes
//
//  Created by demosten on 12/27/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "Generated/_KPToDo.h"

@interface KPToDo : _KPToDo

+(NSString*)generateIdWithLength:(NSInteger)length;

-(void)complete;
-(void)scheduleForDate:(NSDate*)date;

@end
