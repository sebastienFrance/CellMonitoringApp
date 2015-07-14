//
//  CellNeighbors2HTMLTable.m
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 15/02/2015.
//
//

#import "CellNeighbors2HTMLTable.h"
#import "NeighborOverlay.h"
#import "CellMonitoring.h"
#import "Utility.h"
#import "HistoricalCellNeighborsData.h"
#import "NeighborsDataSourceUtility.h"
#import "DateUtility.h"

@implementation CellNeighbors2HTMLTable

+(NSString*) exportCellNeighbors:(NSArray*) neighbors sectionTitle:(NSString*) title{
    NSMutableString* HTMLNeighbors = [[NSMutableString alloc] init];
    
    [HTMLNeighbors appendFormat:@"<h2> %@ </h2>", title];
    
    [HTMLNeighbors appendFormat:@"%@", [CellNeighbors2HTMLTable exportCellNeighbors:neighbors]];
    
    return HTMLNeighbors;

}


+(NSString*) exportCellNeighbors:(NSArray*) neighbors {
    NSMutableString* HTMLNeighbors = [[NSMutableString alloc] init];
    
    // style="width: 100%;"
    if (neighbors == Nil) {
        [HTMLNeighbors appendFormat:@"<p>Neighbors couldn't be collected</p>"];
    } else if (neighbors.count == 0) {
        [HTMLNeighbors appendFormat:@"<p>No neighbors on this cell</p>"];
    } else {
        [HTMLNeighbors appendFormat:@"<table border=\"1\">"];
        [HTMLNeighbors appendFormat:@"<tr>"];
        
        //th style="width:300px"
        [HTMLNeighbors appendFormat:@"<th> Target Cell</th>"];
        [HTMLNeighbors appendFormat:@"<th> Type </th>"];
        [HTMLNeighbors appendFormat:@"<th> DLEARFCN </th>"];
        [HTMLNeighbors appendFormat:@"<th> Frequency </th>"];
        [HTMLNeighbors appendFormat:@"<th> Distance </th>"];
        [HTMLNeighbors appendFormat:@"<th> No Remove </th>"];
        [HTMLNeighbors appendFormat:@"<th> No HO </th>"];
        [HTMLNeighbors appendFormat:@"<th> Measured by ANR </th>"];
        [HTMLNeighbors appendFormat:@"</tr>"];
        
        for (NeighborOverlay* currentNeighbors in neighbors) {
            [HTMLNeighbors appendFormat:@"%@", [CellNeighbors2HTMLTable convertNeighborToHTML:currentNeighbors]];
        }
        
        [HTMLNeighbors appendString:@"</table>"];
    }
    
    
    return HTMLNeighbors;
    
}

+(NSString*) exportCellNeighborsHistorical:(HistoricalCellNeighborsData*) historicalNeighbor {
    NSString* theTilte = [NSString stringWithFormat:@"Neighbors (%@)", [DateUtility getShortGMTDate:historicalNeighbor.currentDate]];
    return [CellNeighbors2HTMLTable exportCellNeighborsDatasource:historicalNeighbor.currentNeighbors sectionTitle:theTilte];
}

+(NSString*) exportCellNeighborsDatasource:(NeighborsDataSourceUtility*) neighborDatasource sectionTitle:(NSString*) theTitle {
    NSMutableString* HTMLNeighbors = [[NSMutableString alloc] init];
    
    if (theTitle != Nil) {
        [HTMLNeighbors appendFormat:@"<h2> %@ </h2>", theTitle];
    }
    
    [HTMLNeighbors appendFormat:@"<ul><li>Intra-Frequencies: %lu </li>", (unsigned long)neighborDatasource.neighborsIntraFreq.count];
    [HTMLNeighbors appendFormat:@"<li>Inter-Frequencies: %lu </li>", (unsigned long)neighborDatasource.neighborsInterFreq.count];
    [HTMLNeighbors appendFormat:@"<li>InterRAT: %lu </li>", (unsigned long)neighborDatasource.neighborsInterRAT.count];
    [HTMLNeighbors appendFormat:@"<li>Measured by ANR: %lu </li></ul>", (unsigned long)neighborDatasource.neighborsByANR.count];
    
    [HTMLNeighbors appendFormat:@"<h3> Intra-Frequencies </h3>"];
    [HTMLNeighbors appendFormat:@"%@", [CellNeighbors2HTMLTable exportCellNeighbors:neighborDatasource.neighborsIntraFreq]];
    [HTMLNeighbors appendFormat:@"<h3> Inter-Frequencies </h3>"];
    [HTMLNeighbors appendFormat:@"%@", [CellNeighbors2HTMLTable exportCellNeighbors:neighborDatasource.neighborsInterFreq]];
    [HTMLNeighbors appendFormat:@"<h3> Inter-RAT </h3>"];
    [HTMLNeighbors appendFormat:@"%@", [CellNeighbors2HTMLTable exportCellNeighbors:neighborDatasource.neighborsInterRAT]];
    return HTMLNeighbors;
}


+(NSString*) convertNeighborToHTML:(NeighborOverlay*) theNeighbor {
    NSMutableString* HTMLNeighbor = [[NSMutableString alloc] init];
    [HTMLNeighbor appendFormat:@"<tr>"];
    
    
    if (theNeighbor.targetCell == Nil) {
        [HTMLNeighbor appendFormat:@"<td>%@</td>", theNeighbor.targetCellId];
    } else {
        [HTMLNeighbor appendFormat:@"<td>%@</td>", theNeighbor.targetCell.id];
    }
    
    [HTMLNeighbor appendFormat:@"<td>%@</td>", theNeighbor.NRTypeString];
    [HTMLNeighbor appendFormat:@"<td>%@</td>", theNeighbor.dlFrequency];
    [HTMLNeighbor appendFormat:@"<td>%@</td>", [Utility displayShortDLFrequency:[Utility computeNormalizedDLFrequency:theNeighbor.dlFrequency]]];
    [HTMLNeighbor appendFormat:@"<td>%@</td>", theNeighbor.distance];
    [HTMLNeighbor appendFormat:@"<td>%@</td>", theNeighbor.noHo ? @"True" : @"False"];
    [HTMLNeighbor appendFormat:@"<td>%@</td>", theNeighbor.noRemove ? @"True" : @"False"];
    [HTMLNeighbor appendFormat:@"<td>%@</td>", theNeighbor.measuredbyANR ? @"True" : @"False"];
    [HTMLNeighbor appendFormat:@"</tr>"];
    return HTMLNeighbor;
}


@end
