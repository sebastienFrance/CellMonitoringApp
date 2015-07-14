//
//  VisitedCells.h
//  iMonitoring
//
//  Created by sébastien brugalières on 30/04/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface VisitedCells : NSManagedObject

@property (nonatomic, retain) NSString * cellInternalName;
@property (nonatomic, retain) NSDate * lastVisitedDate;
@property (nonatomic, retain) NSNumber * visitedCount;
@property (nonatomic, retain) NSNumber * techno;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * latitude;

@end
