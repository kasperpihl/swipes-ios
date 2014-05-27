
#import "KPParseCoreData.h"
#import "KPAttachment.h"

NSString* const EVERNOTE_SERVICE = @"evernote";
NSString* const DROPBOX_SERVICE = @"dropbox";

@interface KPAttachment ()

@end


@implementation KPAttachment

+ (instancetype)attachmentForService:(NSString *)service title:(NSString *)title identifier:(NSString *)identifier
{
    NSAssert([KPAttachment supportsService:service], @"Called with unsupported service: %@", service);
    KPAttachment* attachment = [KPAttachment MR_createInContext:KPCORE.context];
    attachment.identifier = identifier;
    attachment.title = title;
    attachment.service = service;
    return attachment;
}

+ (BOOL)supportsService:(NSString *)service
{
    // we can use some smarter way when we have
    return ([EVERNOTE_SERVICE isEqualToString:service] || [DROPBOX_SERVICE isEqualToString:service]);
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
