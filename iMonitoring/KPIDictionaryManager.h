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
@class KPI;

@interface KPIDictionaryManager : NSObject


@property (nonatomic) KPIDictionary* defaultKPIDictionary;
@property (nonatomic, readonly) NSArray<KPIDictionary*>* KPIDictionaries;
@property (nonatomic, readonly) NSString* defaultKPIDictionaryName;

+ (KPIDictionaryManager*) sharedInstance;

- (void) addKPIDictionary:(KPIDictionary*) dictionary;
-(NSArray<KPI*>*) getKPIsFromSection:(NSInteger) section technology:(DCTechnologyId) cellTechnology;
-(KPI*) getKPI:(DCTechnologyId) cellTechnology indexPath:(NSIndexPath*) indexPath;
@end
