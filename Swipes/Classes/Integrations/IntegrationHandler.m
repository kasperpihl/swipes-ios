//
//  IntegrationHandler.m
//  Swipes
//
//  Created by Kasper Pihl Tornøe on 21/07/14.
//  Copyright (c) 2014 Pihl IT. All rights reserved.
//

#import "IntegrationHandler.h"

@implementation IntegrationHandler
static IntegrationHandler *sharedObject;
+(IntegrationHandler *)sharedInstance{
    if(!sharedObject){
        sharedObject = [[IntegrationHandler allocWithZone:NULL] init];
    }
    return sharedObject;
}

-(NSDictionary *)getIntegration:(Integrations)integration{
    return @{ @"tag":@"swipes" };
}

-(void)setIntegration:(Integrations)integration value:(NSDictionary *)value{

}

-(NSDictionary *)getAllIntegrations{
    return @{ [self keyForIntegration:IntegrationEvernote] : [self getIntegration:IntegrationEvernote] };
}

-(NSString *)keyForIntegration:(Integrations)integration{
    switch (integration) {
        case IntegrationEvernote:
            return @"Evernote";
    }
}
@end
