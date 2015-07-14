//
//  CellGroupAnnotationView.m
//  iMonitoring
//
//  Created by sébastien brugalières on 21/12/2013.
//
//

#import "CellGroupAnnotationView.h"
#import "MapDelegateItf.h"

@implementation CellGroupAnnotationView

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code here.
    }
    return self;
   
}


- (void)showDetails:(id)sender
{
    // Mandatory called by the accessory callout from the pin even if it's empty!
    [self.theMapView deselectAnnotation:self.annotation animated:YES];

    CellMonitoringGroup* theSelectedCell = self.cellGroup;
    [self.mapDelegate cellGroupSelectedOnMap:theSelectedCell annotationView:self];
}

- (CellMonitoringGroup*) cellGroup {
    return (CellMonitoringGroup*) self.annotation;
}

@end
