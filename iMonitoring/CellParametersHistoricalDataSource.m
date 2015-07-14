//
//  CellParametersHistoricalDataSource.m
//  CellMonitoring
//
//  Created by Sébastien Brugalières on 09/03/2015.
//
//

#import "CellParametersHistoricalDataSource.h"
#import "DateUtility.h"
#import "CellParameterUtility.h"
#import "HistoricalParameters.h"
#import "Parameters.h"

@interface CellParametersHistoricalDataSource()

@property (nonatomic, weak) CellMonitoring* theCell;
@property (nonatomic, weak) id<CellParametersHistoricalDataSourceDelegate> theDelegate;

@property (nonatomic) NSArray* theHistoricalData;

@end


@implementation CellParametersHistoricalDataSource

- (id) init:(id<CellParametersHistoricalDataSourceDelegate>) delegate {
    if (self = [super init]) {
        _theDelegate = delegate;
    }
    
    return self;
}

-(void) loadData:(CellMonitoring *)cell {
    
    self.theCell = cell;
    [RequestUtilities getCellParametersWithHistorical:self.theCell delegate:self clientId:@"cellParametersHistorical"];
}

#pragma mark - HTMLDataResponse protocol
- (void) dataReady: (id) theData clientId:(NSString *)theClientId {
    NSArray* data = theData;
    
    NSMutableArray* allHistoricalDataArray = [[NSMutableArray alloc] initWithCapacity:data.count];

    for (NSDictionary* currentParamValuesForDate in data) {
        HistoricalParameters* currentHistoricalParameters = [CellParametersHistoricalDataSource historicalDataFromJSON:currentParamValuesForDate];
        [allHistoricalDataArray addObject:currentHistoricalParameters];
    }
    
    // order the data by date
    self.theHistoricalData = [allHistoricalDataArray sortedArrayUsingSelector:@selector(compareWithDate:)];
    [self buildHistoricalParametersDifferences];

    [self.theDelegate cellParametersHistoricalResponse:self.theCell error:Nil];
}

-(void) buildHistoricalParametersDifferences {
    
    for (NSUInteger i = 0; i < (self.theHistoricalData.count - 1); i++) {
        HistoricalParameters* currentHistoricalNRs = self.theHistoricalData[i];
        HistoricalParameters* previousHistoricalNRs = self.theHistoricalData[i+1];
        [currentHistoricalNRs differencesWith:previousHistoricalNRs];
    }
}

+(HistoricalParameters* ) historicalDataFromJSON:(NSDictionary*) currentParametersValuesForDate {

    NSArray* currentParamValues = currentParametersValuesForDate[@"CellsWithParameters"];
    Parameters* parameterList = [CellParameterUtility buildParameters:currentParamValues];
    
    NSString* currentDateString = currentParametersValuesForDate[@"Date"];
    NSDate* currentDate = [DateUtility getDateFromShortString:currentDateString];
    
    return [[HistoricalParameters alloc] initWithDateAndParameters:currentDate parameters:parameterList];
}


- (void) connectionFailure:(NSString*) theClientId {
    NSError* error = [[NSError alloc] initWithDomain:@"Communication Error" code:1 userInfo:Nil];
    [self.theDelegate cellParametersHistoricalResponse:self.theCell error:error];
}



@end
