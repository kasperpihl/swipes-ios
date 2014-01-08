//
//  KitLocate.h
//  SDKsimple
//
//  Created by Ron Miller on 10/20/12.
//
//

//-------------------------
#define KL_APP_VERSION 4.12
//-------------------------


#import <Foundation/Foundation.h>
#import <KitLocate/KLLocation.h>
#import <KitLocate/KLStatisticsServices.h>
#import <KitLocate/KLGeneralUtilities.h>
#import <UIKit/UIKit.h>

#import <KitLocate/KLPlace.h>

//#warning debug delete!
//#import "KLRestClient.h"

@interface KitLocate : NSObject

/*! Initialize KitLocate. Call this function once as sooner as you can (before you start any KitLocate's activity)
 * \param delegate A reference to a delegate object that recieves various callback methods from KitLocate (This object should implement <KitLocateDelegate> protocol)
 * \param strApiKey the API Key you get when register in KitLocate's dashboard
 */
+ (void)initKitLocateWithDelegate:(id<KitLocateDelegate>)delegate APIKey:(NSString*)strApiKey;

/*! Initialize KitLocate. Call this function once as sooner as you can (before you start any KitLocate's activity)
 * \param delegate A reference to a delegate object that recieves various callback methods from KitLocate (This object should implement <KitLocateDelegate> protocol)
 * \param strApiKey the API Key you get when register in KitLocate's dashboard
 * \param isPList (default true) set false if your app isn't allowed to use background location (you haven't add the 'Location' flag to 'UIBackgroundModes' in your .plist file)
 * \param shouldPreventLocationServices (default false) set true if you don't want any of KitLocate's services
 */
+ (void)initKitLocateWithDelegate:(id<KitLocateDelegate>)delegate APIKey:(NSString*)strApiKey UsePlistLocationFlag:(bool)isPList PreventLocationServices:(bool)shouldPreventLocationServices;

/*! Stop all KitLocate's activities - not recommended (will affect your statistics). Probably it's better to unregister the services you have registered before
*/
+ (void)shutKitLocate;


// User ID

/*! retrieve the user's unique identifier saved before in KitLocate
 * \return The identifier
 */
+(NSString *)getKitLocateUserID;

/*! In order to follow your users' behavior section, it's recommended that you give KitLocate a unique identifier per user (personal ID for example)
 * \param strID The identifier
 */
+(void)setUniqueUserID:(NSString *)strID;


// LOG

//#ifdef KL_DEBUG_LOG

+(void)writeLog:(NSString *)strString logWithContext:(BOOL)blnContextLog;
+(NSArray *)readLog;
+(void)presentLog:(UIViewController *)vwCon;
+(NSString *)getLogString;

//#endif

extern bool bDidInitTookMainThread;

@end
