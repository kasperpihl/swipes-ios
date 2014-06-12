#import "_KPAttachment.h"

extern NSString* const EVERNOTE_SERVICE;
extern NSString* const DROPBOX_SERVICE;

@interface KPAttachment : _KPAttachment {}

+ (instancetype)attachmentForService:(NSString *)service title:(NSString *)title identifier:(NSString *)identifier sync:(BOOL)sync;
+ (instancetype)attachmentForService:(NSString *)service title:(NSString *)title identifier:(NSString *)identifier sync:(BOOL)sync
                           inContext:(NSManagedObjectContext*)context;
+ (NSArray*)supportedServices;
+ (BOOL)supportsService:(NSString *)service;
- ( BOOL )isEqualToDictionary:(NSDictionary*)object;
- (NSDictionary *)jsonForSaving;

@end
