//
//  NeighborOverlay.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 14/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NeighborOverlay.h"
#import "CellMonitoring.h"
#import "UserPreferences.h"
#import "BasicTypes.h"

@implementation NeighborOverlay 


static const NSString* PARAM_noHo = @"noHo";
static const NSString* PARAM_noRemove = @"noRemove";
static const NSString* PARAM_dlFrequency = @"dlFrequency";
static const NSString* PARAM_measuredByANR = @"measuredByANR";
static const NSString* PARAM_targetCell = @"targetCell";
static const NSString* PARAM_technoTargetCell = @"technoTarget";


- (id) initWithDictionary:(NSDictionary *)neighborDictionary source:(CellMonitoring*) sourceCell target:(CellMonitoring*) targetCell{
    if (self = [super init]) {
        _sourceCell = sourceCell;
        _targetCell = targetCell;
        _targetCellId = neighborDictionary[PARAM_targetCell];
        
        NSString* noHo = neighborDictionary[PARAM_noHo];
        NSString* noRemove = neighborDictionary[PARAM_noRemove];
        NSString* measuredByANR = neighborDictionary[PARAM_measuredByANR];
        NSString* technoTargetCell = neighborDictionary[PARAM_technoTargetCell];
        
        if ([noHo isEqualToString:@"true"]) {
            _noHo = TRUE;
        } else {
            _noHo = FALSE;
        }
        
        if ([noRemove isEqualToString:@"true"]) {
            _noRemove = TRUE;
        } else {
            _noRemove = FALSE;
        }
        
        if ([measuredByANR isEqualToString:@"true"]) {
            _measuredbyANR = TRUE;
        } else {
            _measuredbyANR = FALSE;
        }
        
        _dlFrequency = neighborDictionary[PARAM_dlFrequency];
        
        _NRType = [BasicTypes getNRTypeFromSource:_sourceCell.cellTechnology sourceCellFrequency:_sourceCell.dlFrequency
                                 targetCellTechno:[BasicTypes getTechnoFromName:technoTargetCell] targetCellFrequency:_dlFrequency];
        
        [self initializeDistanceAndCoordinates];
   }

    return self;
    
}

- (void) initializeDistanceAndCoordinates {
    if ((_sourceCell != Nil) && (_targetCell != Nil)) {
        
        CLLocationCoordinate2D coordinates[2];
        coordinates[0] = _sourceCell.coordinate;
        coordinates[1] = _targetCell.coordinate;
        
        CLLocation *targetLoc = [[CLLocation alloc] initWithLatitude:_targetCell.coordinate.latitude longitude:_targetCell.coordinate.longitude];
        
        CLLocation *sourceLoc = [[CLLocation alloc] initWithLatitude:_sourceCell.coordinate.latitude longitude:_sourceCell.coordinate.longitude];
        _distanceSourceTarget = [sourceLoc distanceFromLocation:targetLoc];
        
        _thePolyline = [MKPolyline polylineWithCoordinates:coordinates count:2];
    }
}

- (NSString*) NRTypeString {
    return [BasicTypes getNRType:_NRType];
}


// Coordinate used to display the annotation on the Map. Offset is not 0 if several cells have the same coordinates
- (CLLocationCoordinate2D)coordinate;
{
    return _sourceCell.coordinate;
}


- (MKMapRect) boundingMapRect {
  return _thePolyline.boundingMapRect;
}


- (BOOL)intersectsMapRect:(MKMapRect)mapRect {
    return [_thePolyline intersectsMapRect:mapRect];
}

- (NSString*) distance {
    double distanceMeter = floor(_distanceSourceTarget);
    if (distanceMeter > 1000.0) {
        int km = floor(distanceMeter / 1000.0);
        int meter = distanceMeter - (km * 1000);
        if (meter > 0) {
            return [NSString stringWithFormat:@"%d km %d m",km, meter];
        } else {
            return [NSString stringWithFormat:@"%d km %d m",km, meter];
        }
    } else {
        return [NSString stringWithFormat:@"%d m", (int) distanceMeter];        
    }
}

- (NSComparisonResult) compareDistance:(NeighborOverlay *)otherObject {
    if (otherObject.distanceSourceTarget == self.distanceSourceTarget) {
        return NSOrderedSame;
    } else if (otherObject.distanceSourceTarget > self.distanceSourceTarget) {
        return  NSOrderedDescending;
    } else {
        return  NSOrderedAscending;
    }
    
}
- (NSComparisonResult) compareDistanceFromShortest:(NeighborOverlay *)otherObject {
    if (otherObject.distanceSourceTarget == self.distanceSourceTarget) {
        return NSOrderedSame;
    } else if (otherObject.distanceSourceTarget > self.distanceSourceTarget) {
        return  NSOrderedAscending;
    } else {
        return  NSOrderedDescending;
    }
    
}

- (MKPolylineRenderer*) polylineView {
    
    MKPolyline* thePoly = _thePolyline;
    
    MKPolylineRenderer*    aView = [[MKPolylineRenderer alloc] initWithPolyline:thePoly];
    
#if TARGET_OS_IPHONE
    if (_noHo) {
        if (_noRemove) {
            aView.strokeColor = [[UIColor redColor] colorWithAlphaComponent:0.4];
        } else {
            aView.strokeColor = [[UIColor orangeColor] colorWithAlphaComponent:0.4];
        }
    } else {
        if (_noRemove) {
            aView.strokeColor = [[UIColor greenColor] colorWithAlphaComponent:0.8];
        } else {
            aView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.4];
        }
    }
#else
    if (_noHo) {
        if (_noRemove) {
            aView.strokeColor = [[NSColor redColor] colorWithAlphaComponent:0.4];
        } else {
            aView.strokeColor = [[NSColor orangeColor] colorWithAlphaComponent:0.4];
        }
    } else {
        if (_noRemove) {
            aView.strokeColor = [[NSColor greenColor] colorWithAlphaComponent:0.8];
        } else {
            aView.strokeColor = [[NSColor blueColor] colorWithAlphaComponent:0.4];
        }
    }
#endif
    
    if (_NRType == NRInterRAT) {
        aView.lineWidth = 10;
        aView.lineDashPhase = 0.0;
        aView.lineDashPattern = @[@10, @20];
    } else {
        if ([_sourceCell.dlFrequency isEqualToString:_dlFrequency]) {
            aView.lineWidth = 10;
            aView.lineDashPhase = 0.0;
            aView.lineDashPattern = @[@20, @40];
        } else {
            aView.lineWidth = 10;
            aView.lineDashPhase = 0.0;
            aView.lineDashPattern = @[@10, @40, @50,@40];
        }
    }
    
    aView.lineCap = _measuredbyANR ? kCGLineCapSquare:kCGLineCapRound;
    
    return aView;
}


+ (NSArray*) getNeighborWithDistanceGreaterThanMin:(NSArray*) neighbors {
    NSUInteger minNeighborDistance = [UserPreferences sharedInstance].NeighborDistanceMinInMeters;    
    if (minNeighborDistance == 0) {
        return neighbors;
    }
    
    NSMutableArray *NRs = [[NSMutableArray alloc] init];
    for (NeighborOverlay* currNeighbor in neighbors) {
        if (currNeighbor.distanceSourceTarget > minNeighborDistance) {
            [NRs addObject:currNeighbor];
        }
    }
    return NRs;
}

+(NSArray*) getFilteredNeighborOverlayFor:(NSArray*) neighbors {
    NSArray* sourceNRs = [NeighborOverlay getNeighborWithDistanceGreaterThanMin:neighbors];
    UserPreferences* userPrefs = [UserPreferences sharedInstance];
    
    NSMutableArray* filteredNRs = [[NSMutableArray alloc] initWithCapacity:sourceNRs.count];
    for (NeighborOverlay* neighbor in sourceNRs) {
        
        if (userPrefs.isDisplayNeighborsByANR == TRUE) {
            if (neighbor.measuredbyANR == FALSE) {
                continue;
            }
        }
        
        if (neighbor.noHo == FALSE) {
            if (neighbor.noRemove == TRUE) { // NoHo = FALSE && NoRemove = TRUE
                if (userPrefs.isDisplayNeighborsWhiteListed == FALSE) {
                    continue;
                }
            } else { // NoHo = FALSE && NoRemove = FALSE
                if (userPrefs.isDisplayNeighborsNotBLNotWL == FALSE) {
                    continue;
                }
            }
        } else {
            if (neighbor.noRemove == TRUE) { // NoHo = TRUE && NoRemove = TRUE
                if (userPrefs.isDisplayNeighborsBlackListed == FALSE) {
                    continue;
                }
            } else { // NoHo = TRUE && NoRemove = FALSE
                if (userPrefs.isDisplayNeighborsNotBLNotWL == FALSE) {
                    continue;
                }
            }
        }
        [filteredNRs addObject:neighbor];
    }
    
    return filteredNRs;
}





@end
