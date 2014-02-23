#import "_KPAttachment.h"

@interface KPAttachment : _KPAttachment {}

+ (instancetype)attachmentForService:(NSString *)service title:(NSString *)title identifier:(NSString *)identifier;
- (NSString *)jsonForSaving;

@end
