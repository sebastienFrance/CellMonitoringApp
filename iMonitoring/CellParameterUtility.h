//
//  CellParameterUtility.h
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 09/03/2015.
//
//

#import <Foundation/Foundation.h>

@class Parameters;

@interface CellParameterUtility : NSObject


+(Parameters*) buildParameters:(NSArray*) cellParameters;

@end
