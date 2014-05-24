#import "_KPAttachment.h"

extern NSString* const EVERNOTE_SERVICE;
extern NSString* const DROPBOX_SERVICE;

@interface KPAttachment : _KPAttachment {}

+ (instancetype)attachmentForService:(NSString *)service title:(NSString *)title identifier:(NSString *)identifier;
+ (BOOL)supportsService:(NSString *)service;

- (NSDictionary *)jsonForSaving;

@end
