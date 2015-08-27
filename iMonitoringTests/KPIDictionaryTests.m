//
//  KPIDictionnaryTests.m
//  iMonitoring
//
//  Created by sébastien brugalières on 10/02/13.
//
//

#import "KPIDictionaryTests.h"
#import "KPI.h"
#import "KPIDictionary.h"


@interface KPIDictionaryTests()

@property(nonatomic) KPIDictionary* theKPIDictionary;
@property(nonatomic) KPIDictionary* theKPIDictionaryWithoutWCDMA;

@end

@implementation KPIDictionaryTests

static NSUInteger const LTE_KPI_NUMBER = 10;
static NSUInteger const WCDMA_KPI_NUMBER = 15;
static NSUInteger const GSM_KPI_NUMBER = 12;

static NSUInteger const KPI_NUMBER_PER_DOMAIN = 4;

- (void)setUp
{
    [super setUp];
    
    self.theKPIDictionary = [[KPIDictionary alloc] init:@"MyDictionary" description:@"description"];
    
    [self addKPIForTechno:@"LTE" KPINumber:LTE_KPI_NUMBER KPIDictionary:self.theKPIDictionary];
    [self addKPIForTechno:@"WCDMA" KPINumber:WCDMA_KPI_NUMBER KPIDictionary:self.theKPIDictionary];
    [self addKPIForTechno:@"GSM" KPINumber:GSM_KPI_NUMBER KPIDictionary:self.theKPIDictionary];

    self.theKPIDictionaryWithoutWCDMA = [[KPIDictionary alloc] init:@"MyDictionary" description:@"description"];
    
    [self addKPIForTechno:@"LTE" KPINumber:LTE_KPI_NUMBER KPIDictionary:self.theKPIDictionaryWithoutWCDMA];
    [self addKPIForTechno:@"GSM" KPINumber:GSM_KPI_NUMBER KPIDictionary:self.theKPIDictionaryWithoutWCDMA];
}

- (void) addKPIForTechno:(NSString*) theTechno KPINumber:(NSUInteger)count KPIDictionary:(KPIDictionary*) theKPIDictionary{
    for (NSUInteger i = 0; i < count; i++) {
        
        for (NSUInteger j = 0; j < KPI_NUMBER_PER_DOMAIN; j++) {
            NSString* KPIName = [NSString stringWithFormat:@"KPIName_%@_%lu_%lu",theTechno,(unsigned long)j,(unsigned long)i];
            NSString* KPIInternalName = [NSString stringWithFormat:@"KPIInternalName_%@_%lu_%lu",theTechno,(unsigned long)j,(unsigned long)i];
            NSString* KPIDomainName = [NSString stringWithFormat:@"Domain_%lu",(unsigned long)j];
            
            NSDictionary* simpleKPI = @{@"name": KPIName,
                                       @"internalName": KPIInternalName,
                                       @"shortDescription": @"description",
                                       @"formula": @"formula",
                                       @"domain": KPIDomainName,
                                       @"unit": @"Req",
                                       @"direction": @"",
                                       @"low": @"",
                                       @"medium": @"",
                                       @"high": @"",
                                       @"relatedKPI": @""};

            KPI* theKPI = [[KPI alloc] init:simpleKPI techno:theTechno];
            [theKPIDictionary addKPI:theKPI];
        }
    }
   
}


- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}


- (void)testProperties {
    XCTAssertEqualObjects(self.theKPIDictionary.name, @"MyDictionary", @"Property name has wrong value");
    XCTAssertEqualObjects(self.theKPIDictionary.theDescription, @"description", @"Property description has wrong value");
}

- (void)testMethods {
    NSArray<KPI*>* LTEKPIs = [self.theKPIDictionary getKPIs:DCTechnologyLTE];
    KPI* theKPI;

    XCTAssertEqual(LTEKPIs.count, LTE_KPI_NUMBER * KPI_NUMBER_PER_DOMAIN, @"Wrong number of KPIs in LTE dictionary");

    theKPI = LTEKPIs[0];
    XCTAssertEqual(theKPI.technology, DCTechnologyLTE, @"Wrong technology for KPI in LTE Dictionary");
    
    NSDictionary<NSString*, NSArray<KPI*>*> *KPIPerDomain = [self.theKPIDictionary getKPIsPerDomain:DCTechnologyLTE];
    XCTAssertEqual(KPIPerDomain.count, KPI_NUMBER_PER_DOMAIN,  @"Wrong number of domain in LTE Dictionary");

    theKPI = [self.theKPIDictionary findKPIbyInternalName:@"unknown"];
    XCTAssertTrue(theKPI == Nil, @"found KPI in LTE Dictionary that doesn't exists");

    theKPI = [self.theKPIDictionary findKPIbyInternalName:@"KPIInternalName_LTE_1_2"];
    XCTAssertFalse(theKPI == Nil, @"Cannot find KPI in LTE Dictionary by internal name");
    XCTAssertEqualObjects(theKPI.internalName, @"KPIInternalName_LTE_1_2" , @"Found KPI has not the right internal name");
    
    NSArray<NSString*> *sectionsHeader = [self.theKPIDictionary getSectionsHeader:DCTechnologyLTE];
    XCTAssertEqual(sectionsHeader.count, KPI_NUMBER_PER_DOMAIN, @"Wrong number of section header");
    
    NSString* header = sectionsHeader[0];
    XCTAssertEqualObjects(header, @"Domain_0", @"Wrong name for first header");
    
    header = [sectionsHeader lastObject];
    XCTAssertEqualObjects(header, @"Domain_3", @"Wrong name for last header");
    
    NSArray* WCDMAKPIs = [self.theKPIDictionary getKPIs:DCTechnologyWCDMA];
    XCTAssertEqual(WCDMAKPIs.count, WCDMA_KPI_NUMBER * KPI_NUMBER_PER_DOMAIN, @"Wrong number of KPIs in WCDMA dictionary");
    
    theKPI = WCDMAKPIs[0];
    XCTAssertEqual(theKPI.technology, DCTechnologyWCDMA, @"Wrong technology for KPI in WCDMA Dictionary");

    NSArray* GSMKPIs = [self.theKPIDictionary getKPIs:DCTechnologyGSM];
    XCTAssertEqual(GSMKPIs.count, GSM_KPI_NUMBER * KPI_NUMBER_PER_DOMAIN, @"Wrong number of KPIs in GSM dictionary");
    
    theKPI = GSMKPIs[0];
    XCTAssertEqual(theKPI.technology, DCTechnologyGSM, @"Wrong technology for KPI in GSM Dictionary");
    
    WCDMAKPIs = [self.theKPIDictionaryWithoutWCDMA getKPIs:DCTechnologyWCDMA];
    XCTAssertEqual(WCDMAKPIs.count, (NSUInteger) 0, @"KPI without WCDMA section has returned non empty KPI list");
    
}


@end
