#import "_KPTag.h"

@interface KPTag : _KPTag {}
+(KPTag*)addTagWithString:(NSString *)string save:(BOOL)save;
+(void)deleteTagWithString:(NSString*)string save:(BOOL)save;
+(NSArray *)allTagsAsStrings;
@end
