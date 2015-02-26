//
//  IntegrationProvider.h
//  Swipes
//
//  Created by demosten on 2/24/15.
//  Copyright (c) 2015 Pihl IT. All rights reserved.
//

#ifndef Swipes_IntegrationProvider_h
#define Swipes_IntegrationProvider_h

@protocol IntegrationProvider <NSObject>

- (NSString *)integrationTitle;
- (NSString *)integrationSubtitle;
- (NSString *)integrationIcon;
- (BOOL)integrationEnabled;

@end

#endif
