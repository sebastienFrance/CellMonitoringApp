//
//  KPIDictionaryManager.h
//  iMonitoring
//
//  Created by sébastien brugalières on 09/12/2013.
//
//

#import <Foundation/Foundation.h>
#import "BasicTypes.h"

@class KPIDictionary;

@interface KPIDictionaryManager : NSObject


@property (nonatomic) KPIDictionary* defaultKPIDictionary;
@property (nonatomic, readonly) NSArray* KPIDictionaries;
@property (nonatomic, readonly) NSString* defaultKPIDictionaryName;

+ (KPIDictionaryManager*) sharedInstance;

- (void) addKPIDictionary:(KPIDictionary*) dictionary;

@end
