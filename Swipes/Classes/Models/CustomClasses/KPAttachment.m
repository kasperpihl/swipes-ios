
#import "CoreSyncHandler.h"
#import "KPAttachment.h"

NSString* const EVERNOTE_SERVICE = @"evernote";
NSString* const DROPBOX_SERVICE = @"dropbox";

@interface KPAttachment ()

@end


@implementation KPAttachment

+ (instancetype)attachmentForService:(NSString *)service title:(NSString *)title identifier:(NSString *)identifier sync:(BOOL)sync
{
    return [KPAttachment attachmentForService:service title:title identifier:identifier sync:sync inContext:KPCORE.context];
}
+ (instancetype)attachmentForService:(NSString *)service title:(NSString *)title identifier:(NSString *)identifier sync:(BOOL)sync
                           inContext:(NSManagedObjectContext*)context{
    NSAssert([KPAttachment supportsService:service], @"Called with unsupported service: %@", service);
    KPAttachment* attachment = [KPAttachment MR_createInContext:context];
    attachment.identifier = identifier;
    attachment.title = title;
    attachment.service = service;
    attachment.sync = @(sync);
    return attachment;
}
+(NSArray*)supportedServices{
    return @[ EVERNOTE_SERVICE, DROPBOX_SERVICE ];
}
+ (BOOL)supportsService:(NSString *)service
{
    // we can use some smarter way when we have
    return ([EVERNOTE_SERVICE isEqualToString:service] || [DROPBOX_SERVICE isEqualToString:service]);
}

-(BOOL)isEqualToDictionary:(NSDictionary *)object{
    
    if( !object || ![object isKindOfClass:[NSDictionary class]] )
        return NO;
    
    if ( ![ [ object objectForKey: @"identifier" ] isEqualToString: self.identifier ] )
        return NO;
    
    if ( ![ [ object objectForKey: @"title" ] isEqualToString: self.title ] )
        return NO;
    
    if ( ![ [ object objectForKey: @"service" ] isEqualToString: self.service ] )
        return NO;
    
    if (![[object objectForKey:@"sync"] boolValue] != self.sync.boolValue)
        return NO;
    return YES;
}
-(NSDictionary *)jsonForSaving
{
    return @{ @"service": self.service, @"identifier": self.identifier, @"title": self.title, @"sync": self.sync };
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"KPAttachment -> service: %@, title: %@, identifier: %@", self.service, self.title, self.identifier];
}

@end
