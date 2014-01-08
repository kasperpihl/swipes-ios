//
//  StatisticsServices.h
//  KitLocate
//
//  Created by Ron Miller on 12/16/12.
//
//

#import <Foundation/Foundation.h>


@interface KLStatisticsServices : NSObject
{
}

/*! Allows you add events at chosen places in your code. You can later watch it on KitLocate's dashboard
 * \param eventName Name of the event. Must containts charecters
 * \param Param String param with additional information. can be @"". for multi-parameter message use the overloaded function
 */
+ (void)logEvent:(NSString*)eventName withParam:(NSString*)Param;

/*! Allows you add events at chosen places in your code. You can later watch it on KitLocate's dashboard
 * \param eventName Name of the event. Must containts charecters
 * \param arrParams Array of string params
 */
+ (void)logEvent:(NSString*)eventName withParams:(NSArray *)arrParams;

//+ (void)CreateLocalNotification:(NSString*)NotificationText;

//Maybe export:
/*
 + (void)GetPOIsFromServer;
 + (void)SendStatisticsToServer;
 */

//Variables to set: (bool)AllowPush, (int)IntervalToConsiderPushOpen,

//
//// Local Push creation
//
//+(void) createPushWithText:(NSString*) strPushText ImageName:(NSString *)strImage IconBadge:(int)nBadge SoundName:(NSString *)strSound;
//+(void) createPushWithText:(NSString*) strPushText ImageName:(NSString *)strImage IconBadge:(int)nBadge SoundName:(NSString *)strSound UserInfo:(NSDictionary *)dicUserInfo TimeIntervalSinceNowInSeconds:(NSTimeInterval)timeInterval;
//+(void) createPushWithText: (NSString*) strPushText ImageName:(NSString *)strImage IconBadge:(int)nBadge SoundName:(NSString *)strSound UserInfo:(NSDictionary *)dicUserInfo TimeIntervalSinceNowInSeconds:(NSTimeInterval)timeInterval withAlertTitle:(NSString *)strAlertTitile AlertButtonTitle:(NSString *)strAlertButtonTitle AlertCancelButtonTitle:(NSString *)strAlertCancelButton AlertDelegate:(id)delegate;
//
//// Push Managment Approval
//
//+(NSArray *)requestPushManagementApprovalWithGeofences:(NSArray *)arrGeofences; //#
//+(NSArray *)requestDebugManagementWithStringParametersArray:(NSArray *)arrStringParams; //#
//
//+(NSArray *)getLastPushManagementApprovalWithGeofences;
//
//// APP STATE
//
//+ (bool)isOnBackground;
//



/*! Generates a list of places visited by the device's user: A place is a location that the device stayed around and not just passed by.
 * \param startTime the earliest date/time for places
 * \param endTime the latest date/time for places
 * \param dicParams more parameters for advanced usage
 */
+ (NSArray*)getPlacesHistorySince:(NSDate*)startTime Until:(NSDate*)endTime AdditionalParams:(NSDictionary*)dicParams;

@end
