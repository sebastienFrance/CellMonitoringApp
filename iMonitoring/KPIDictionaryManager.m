//
//  KPIDictionaryManager.m
//  iMonitoring
//
//  Created by sébastien brugalières on 09/12/2013.
//
//

#import "KPIDictionaryManager.h"
#import "KPIDictionary.h"

@interface KPIDictionaryManager() {
    NSMutableArray* _KPIDictionaries;
}

@end

@implementation KPIDictionaryManager

+(KPIDictionaryManager*)sharedInstance
{
    static dispatch_once_t pred;
    static KPIDictionaryManager *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[KPIDictionaryManager alloc] init];
    });
    return sharedInstance;
}

- (id)init{
    if (self = [super init] ) {
        _KPIDictionaries = [[NSMutableArray alloc] init];
//        _monitoringPeriod = [UserPreferences sharedInstance].KPIDefaultMonitoringPeriod;
//        
//        _isAppStarting = TRUE;
        
    }
    
    return self;
}

// -------- Methods to store the KPI dictionaries ----------
- (void) addKPIDictionary:(KPIDictionary*) dictionary {
    if (_defaultKPIDictionary == Nil) {
        _defaultKPIDictionary = dictionary;
    }
    [_KPIDictionaries addObject:dictionary];
}

- (NSString*) defaultKPIDictionaryName {
    return _defaultKPIDictionary.name;
}


@end
