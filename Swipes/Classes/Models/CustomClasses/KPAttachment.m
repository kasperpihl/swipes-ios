
#import "CoreSyncHandler.h"
#import "KPAttachment.h"

NSString* const EVERNOTE_SERVICE = @"evernote";
NSString* const GMAIL_SERVICE = @"gmail";
NSString* const DROPBOX_SERVICE = @"dropbox";
NSString* const URL_SERVICE = @"url";

@interface KPAttachment ()

@end


@implementation KPAttachment
+( NSArray *)findAttachmentsForService:(NSString*)service identifier:(NSString *)identifier context:(NSManagedObjectContext *)context
{
    if(!context)
        context = KPCORE.context;
    NSPredicate *findPredicate = [NSPredicate predicateWithFormat:@"service = %@ AND identifier = %@",service,identifier];
    return [KPAttachment MR_findAllWithPredicate:findPredicate inContext:context];
}

+ (instancetype)attachmentForService:(NSString *)service title:(NSString *)title identifier:(NSString *)identifier sync:(BOOL)sync
{
    return [KPAttachment attachmentForService:service title:title identifier:identifier sync:sync inContext:KPCORE.context];
}

+ (instancetype)attachmentForService:(NSString *)service title:(NSString *)title identifier:(NSString *)identifier sync:(BOOL)sync
                           inContext:(NSManagedObjectContext*)context
{
    NSAssert([KPAttachment supportsService:service], @"Called with unsupported service: %@", service);
    KPAttachment* attachment = [KPAttachment MR_createEntityInContext:context];
    attachment.identifier = identifier;
    attachment.title = title;
    attachment.service = service;
    attachment.sync = @(sync);
    return attachment;
}

+(NSArray *)allIdentifiersForService:(NSString *)service sync:(BOOL)sync context:(NSManagedObjectContext *)context{
    if(!context)
        context = KPCORE.context;
    NSPredicate *findPredicate = [NSPredicate predicateWithFormat:@"service = %@ AND sync == %@",service,@(sync)];
    NSArray *objects = [KPAttachment MR_findAllWithPredicate:findPredicate inContext:context];
    NSMutableArray *identifiers = [NSMutableArray array];
    for( KPAttachment *attachment in objects ){
        if(attachment && attachment.identifier){
            [identifiers addObject:attachment.identifier];
        }
    }
    return [identifiers copy];
}

+(NSArray*)supportedServices{
    return @[ EVERNOTE_SERVICE, DROPBOX_SERVICE, URL_SERVICE ];
}

+ (BOOL)supportsService:(NSString *)service
{
    // we can use some smarter way when we have
    return ([EVERNOTE_SERVICE isEqualToString:service] || [GMAIL_SERVICE isEqualToString:service] || [DROPBOX_SERVICE isEqualToString:service] || [URL_SERVICE isEqualToString:service]);
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
