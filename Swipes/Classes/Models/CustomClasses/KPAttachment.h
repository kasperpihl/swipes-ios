#import "_KPAttachment.h"

extern NSString* const EVERNOTE_SERVICE;
extern NSString* const GMAIL_SERVICE;
extern NSString* const DROPBOX_SERVICE;

@interface KPAttachment : _KPAttachment {}
+( NSArray *)findAttachmentsForService:(NSString*)service identifier:(NSString*)identifier context:(NSManagedObjectContext*)context;
+ (instancetype)attachmentForService:(NSString *)service title:(NSString *)title identifier:(NSString *)identifier sync:(BOOL)sync;
+ (instancetype)attachmentForService:(NSString *)service title:(NSString *)title identifier:(NSString *)identifier sync:(BOOL)sync
                           inContext:(NSManagedObjectContext*)context;
+ (NSArray*)supportedServices;
+ (NSArray*)allIdentifiersForService:(NSString*)service sync:(BOOL)sync context:(NSManagedObjectContext*)context;
+ (BOOL)supportsService:(NSString *)service;
- ( BOOL )isEqualToDictionary:(NSDictionary*)object;
- (NSDictionary *)jsonForSaving;

@end
