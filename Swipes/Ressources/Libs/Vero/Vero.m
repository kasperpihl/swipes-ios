//
//  Vero.m
//  VeroTest
//
//  Created by James Lamont on 16/04/13.
//  Copyright (c) 2013 James Lamont. All rights reserved.
//

#import "Vero.h"

@implementation Vero

@synthesize authToken;
@synthesize logging;
@synthesize developmentMode;
static Vero *sharedObject;
+(Vero *)shared{
    if(!sharedObject) sharedObject = [[Vero allocWithZone:NULL] init];
    return sharedObject;
}
- (void) makeApiCall: (NSString*)url method:(NSString*)method params: (NSDictionary*)params completionHandler:(VeroBlock)block{
    NSURL *veroUrl              = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:veroUrl];
    NSError *error;
    NSMutableData *requestBody = [[NSJSONSerialization dataWithJSONObject:params
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error] mutableCopy];
    if(self.logging) NSLog(@"%@ %@", method, url);
    [request setHTTPMethod:method];
    [request setHTTPBody:requestBody];
    [request setValue:@"application/json; encoding=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    NSOperationQueue *queue = [NSOperationQueue new];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(connectionError){
            if(block) block(nil,connectionError);
            if(self.logging) NSLog(@"error from Vero %@",connectionError);
        }
        else{
            NSDictionary *parsedJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if(block) block(parsedJSON,nil);
            if(self.logging) NSLog(@"result from Vero %@",parsedJSON);
        }
    }];
}

// Events

- (void) eventsTrack: (NSString*)eventName identity:(NSDictionary*)userProperties data:(NSDictionary*)data completionHandler:(VeroBlock)block{
    NSString* url = @"https://api.getvero.com/api/v2/events/track.json";
    
    NSDictionary* params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                            eventName,       @"event_name",
                            self.authToken,  @"auth_token",
                            userProperties,  @"identity",
                            @(self.developmentMode),         @"development_mode", nil];
    
    if (data) {
        [params setValue:data forKey:@"data"];
    }
    
    [self makeApiCall:url method:@"POST" params:params completionHandler:block];
}

// Users

- (void) usersTrack: (NSString*)userId email:(NSString*)email data:(NSDictionary*)userProperties completionHandler:(VeroBlock)block{
    NSString* url = @"https://api.getvero.com/api/v2/users/track.json";
    
    NSDictionary* params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                            self.authToken, @"auth_token",
                            @(self.developmentMode),        @"development_mode", nil];
    
    if (userId) {
        [params setValue:userId forKey:@"id"];
    }
    if (email) {
        [params setValue:email forKey:@"email"];
    }
    if (userProperties) {
        [params setValue:userProperties forKey:@"data"];
    }
    
    [self makeApiCall:url method:@"POST" params:params completionHandler:block];
}

- (void) usersEdit: (NSString*)userId changes:(NSDictionary*)changes completionHandler:(VeroBlock)block{
    NSString* url = @"https://api.getvero.com/api/v2/users/edit.json";
    
    NSDictionary* params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                            self.authToken, @"auth_token",
                            userId,         @"id",
                            changes,        @"changes",
                            @(self.developmentMode),        @"development_mode", nil];
    
    [self makeApiCall:url method:@"PUT" params:params completionHandler:block];
}

- (void) usersTagsEdit: (NSString*)userId add:(NSArray*)add remove:(NSArray*)remove completionHandler:(VeroBlock)block{
    NSString* url = @"https://api.getvero.com/api/v2/users/tags/edit.json";
    
    NSDictionary* params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                            self.authToken, @"auth_token",
                            userId,         @"id",
                            @(self.developmentMode),        @"development_mode", nil];
    if (add) {
        [params setValue:add forKey:@"add"];
    }
    if (remove) {
        [params setValue:remove forKey:@"remove"];
    }
    
    [self makeApiCall:url method:@"PUT" params:params completionHandler:block];
}

- (void) usersUnsubscribe: (NSString*)userId completionHandler:(VeroBlock)block{
    NSString* url = @"https://api.getvero.com/api/v2/users/unsubscribe.json";
    
    NSDictionary* params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                            self.authToken, @"auth_token",
                            userId,         @"id", nil];
    
    [self makeApiCall:url method:@"POST" params:params completionHandler:block];
}

@end