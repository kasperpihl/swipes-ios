//
//  IntegrationHandler.h
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 21/07/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import <Foundation/Foundation.h>
#define kIntHandle [IntegrationHandler sharedInstance]
typedef enum {
    IntegrationEvernote = 1
} Integrations;

@interface IntegrationHandler : NSObject
+(IntegrationHandler*)sharedInstance;
-(NSDictionary*)getIntegration:(Integrations)integration;
-(void)setIntegration:(Integrations)integration value:(NSDictionary*)value;

-(NSString*)keyForIntegration:(Integrations)integration;

-(NSDictionary*)getAllIntegrations;

@end
