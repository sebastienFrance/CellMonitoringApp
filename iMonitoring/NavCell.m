//
//  NavCell.m
//  iMonitoring
//
//  Created by sébastien brugalières on 23/02/13.
//
//

#import "NavCell.h"
#import "CellMonitoring.h"
#import "CellWithKPIValues.h"


@implementation NavCell

static  NSString* kNavCellCellId = @"CellId";
static  NSString* kNavCellLatitude = @"Lat";
static  NSString* kNavCellLongitude = @"Long";

- (id) init:(NSString*) cellId latitude:(NSString*) theLatitude longitude:(NSString*) theLongitude {
    if (self = [super init]) {
        _cellId = cellId;
        _coordinate.latitude = [theLatitude doubleValue];
        _coordinate.longitude = [theLongitude doubleValue];
   }
    return self;

}

#pragma mark - NSCoding protocol

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.cellId forKey:kNavCellCellId];
    [encoder encodeDouble:self.coordinate.latitude forKey:kNavCellLatitude];
    [encoder encodeDouble:self.coordinate.longitude forKey:kNavCellLongitude];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        _cellId = [decoder decodeObjectForKey:kNavCellCellId];
        _coordinate.latitude = [decoder decodeDoubleForKey:kNavCellLatitude];
        _coordinate.longitude = [decoder decodeFloatForKey:kNavCellLongitude];
    }
    
    return self;
}


#pragma mark - Helper method 

// <?xml version=\"1.0\"?>
// <NavData>
// <Cell id="123346_3" latitude="78.223" longitdude="24.125"/>
// <Cell id="123346_3" latitude="78.223" longitdude="24.125"/>
// </NavData>


+ (NSData*) buildNavigationData:(NSArray*) cells {
    NSMutableString* navigationData = [NavCell createNavDataHeader];
    
    for (CellMonitoring* currentCell in cells) {
        if (currentCell != nil) {
            [NavCell appendNavCell:navigationData cell:currentCell];
        }
    }
    [NavCell appendNavDataEndElement:navigationData];
    
    return [navigationData dataUsingEncoding:NSASCIIStringEncoding];
}

+ (NSData*) buildNavigationDataFromCellKPIs:(NSArray*) cellsKPIs  worstItf:(id<WorstKPIItf>) theWorstItf{
    
    NSMutableString* navigationData = [NavCell createNavDataHeader];
    
    for (CellWithKPIValues* currCell in cellsKPIs) {
        CellMonitoring* currentCell = [theWorstItf getCellbyName:currCell.cellName];
        if (currentCell != nil) {
            [NavCell appendNavCell:navigationData cell:currentCell];
        }
    }
    [NavCell appendNavDataEndElement:navigationData];
    
    return [navigationData dataUsingEncoding:NSASCIIStringEncoding];
}


+ (NSData*) buildNavigationDataForCell:(CellMonitoring*) theCell {
    NSMutableString* navigationData = [NavCell createNavDataHeader];
    [NavCell appendNavCell:navigationData cell:theCell];
    [NavCell appendNavDataEndElement:navigationData];
    
    return [navigationData dataUsingEncoding:NSASCIIStringEncoding];
}


+ (NSMutableString*) createNavDataHeader {
    NSMutableString* navigationData = [[NSMutableString alloc] init];
    [navigationData appendFormat:@"<?xml version=\"1.0\"?>"];
    [navigationData appendFormat:@"<NavData>"];
    
    return navigationData;
}

+ (void) appendNavCell:(NSMutableString*) navigationData cell:(CellMonitoring*) theCell {
    [navigationData appendFormat:@"<Cell id=\"%@\" latitude=\"%f\" longitude=\"%f\"/>",theCell.id, theCell.coordinate.latitude, theCell.coordinate.longitude];
//    [navigationData appendFormat:@"<Cell id=\"%@\" latitude=\"%f\" longitude=\"%f\"/>",theCell.id, [theCell.latitude stringValue], [theCell.longitude stringValue]];
}

+ (void) appendNavCellNoLatLong:(NSMutableString*) navigationData cell:(CellMonitoring*) theCell {
    [navigationData appendFormat:@"<Cell id=\"%@\"/>",theCell.id];
}


+ (void) appendNavDataEndElement:(NSMutableString*) navigationData {
    [navigationData appendFormat:@"</NavData>"];    
}

@end
