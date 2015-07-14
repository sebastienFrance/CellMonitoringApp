//
//  MapDelegate.h
//  iMonitoring
//
//  Created by sébastien brugalières on 21/12/2013.
//
//

#import <Foundation/Foundation.h>

@class CellMonitoringGroup;

@protocol MapDelegateItf<NSObject>

-(void) refreshMapContent;
-(void) cellGroupSelectedOnMap:(CellMonitoringGroup*) cellGroup annotationView:(MKAnnotationView*) annotation;

-(void) mapViewUpdated;

@end
