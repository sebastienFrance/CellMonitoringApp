//
//  KPIDictionary.m
//  iMonitoring
//
//  Created by Sebastien Brugalieres on 11/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "KPIDictionary.h"
#import "KPI.h"
#import "KPIDictionaryManager.h"

@interface KPIDictionary ()

@property (nonatomic) NSMutableArray<KPI*> *lteKPIs;
@property (nonatomic) NSMutableDictionary<NSString*,NSMutableArray<KPI*>*> *lteKPIsPerDomain;

@property (nonatomic) NSMutableArray<KPI*> *wcdmaKPIs;
@property (nonatomic) NSMutableDictionary<NSString*,NSMutableArray<KPI*>*> *wcdmaKPIsPerDomain;

@property (nonatomic) NSMutableArray<KPI*> *gsmKPIs;
@property (nonatomic) NSMutableDictionary<NSString*,NSMutableArray<KPI*>*> *gsmKPIsPerDomain;

@end

@implementation KPIDictionary


#pragma mark - Get KPIs

- (NSArray<KPI*>*) getKPIs:(DCTechnologyId) theTechno {
    switch (theTechno) {
        case DCTechnologyLTE:
            return _lteKPIs;
        case DCTechnologyWCDMA:
            return _wcdmaKPIs;
        case DCTechnologyGSM:
            return _gsmKPIs;
        default:
            return Nil;
    }
}

- (NSDictionary<NSString*,NSArray<KPI*>*>*) getKPIsPerDomain:(DCTechnologyId) theTechno {
    switch (theTechno) {
        case DCTechnologyLTE:
            return _lteKPIsPerDomain;
        case DCTechnologyWCDMA:
            return _wcdmaKPIsPerDomain;
        case DCTechnologyGSM:
            return _gsmKPIsPerDomain;
        default:
            return Nil;
    }
}


- (KPI*) findKPIbyInternalName:(NSString*) theKPIName {
    // look first in LTE
    for (KPI* currKPI in _lteKPIs) {
        if ([currKPI.internalName isEqualToString:theKPIName]) {
            return currKPI;
        }
    }
    
    for (KPI* currKPI in _wcdmaKPIs) {
        if ([currKPI.internalName isEqualToString:theKPIName]) {
            return currKPI;
        }
    }

    for (KPI* currKPI in _gsmKPIs) {
        if ([currKPI.internalName isEqualToString:theKPIName]) {
            return currKPI;
        }
    }

    return Nil;
}

- (KPI*) findKPIbyInternalName:(NSString*) theKPIName forTechno:(DCTechnologyId) technology  {
    
    NSArray<KPI*> *KPIsToLookFor = Nil;
    switch (technology) {
        case DCTechnologyLTE: {
            KPIsToLookFor =  _lteKPIs;
            break;
        }
        case DCTechnologyWCDMA:{
            KPIsToLookFor =  _wcdmaKPIs;
            break;
        }
        case DCTechnologyGSM:{
            KPIsToLookFor =  _gsmKPIs;
            break;
        }
        default:
            return Nil;
    }
    
    for (KPI* currKPI in KPIsToLookFor) {
        if ([currKPI.internalName isEqualToString:theKPIName]) {
            return currKPI;
        }
    }
    
    return Nil;
}

+(NSInteger) row:(NSIndexPath*) indexPath{
    return [indexPath indexAtPosition:1];
}

+(NSInteger) section:(NSIndexPath*) indexPath {
    return [indexPath indexAtPosition:0];
}

+(NSIndexPath*) indexPathForRow:(NSInteger) row inSection:(NSInteger)section {
    NSUInteger path[2];
    path[0] = section;
    path[1] = row;
    return [[NSIndexPath alloc] initWithIndexes:path length:2];
}


- (NSIndexPath*) getPreviousKPIByDomain:(NSIndexPath*) currentIndex techno:(DCTechnologyId) theTechno {

    if (currentIndex == Nil) {
        return Nil;
    }
    
    NSDictionary<NSString*,NSArray<KPI*>*> *theKPIDictionary = [self getKPIsPerDomain:theTechno];
    
    NSInteger currentRow = [KPIDictionary row:currentIndex];
    NSInteger currentSection = [KPIDictionary section:currentIndex];
    
    // decrement the row in the same section
    currentRow--;
    if (currentRow >= 0) {
        return [KPIDictionary indexPathForRow:currentRow inSection:currentSection];
    } else { 
        // move to last row of the previous section
        if (currentSection > 0) {
            NSArray* sectionsHeader = [self getSectionsHeader:theTechno];
            NSArray* sectionContent = theKPIDictionary[sectionsHeader[(currentSection - 1)]];
            return [KPIDictionary indexPathForRow:(sectionContent.count-1) inSection:(currentSection - 1)];
        } else {
            return Nil;
        }
        
    }
    
}

- (NSIndexPath*) getNextKPIByDomain:(NSIndexPath*) currentIndex techno:(DCTechnologyId) theTechno {
    if (currentIndex == Nil) {
        return Nil;
    }

    NSDictionary<NSString*,NSArray<KPI*>*> *theKPIDictionary = [self getKPIsPerDomain:theTechno];

    NSInteger currentRow = [KPIDictionary row:currentIndex];
    NSInteger currentSection = [KPIDictionary section:currentIndex];

    
    NSArray<NSString*> *sectionsHeader = [self getSectionsHeader:theTechno];
    NSArray<KPI*> *sectionContent = theKPIDictionary[sectionsHeader[(currentSection)]];
    
    // increment the row in the same section
    currentRow++;
    if (currentRow < sectionContent.count) {
        return [KPIDictionary indexPathForRow:currentRow inSection:currentSection];
    } else {
        // move to 1st row of the next section
        currentSection++;
        if (currentSection < (theKPIDictionary.count)) {
            return [KPIDictionary indexPathForRow:0 inSection:currentSection];
        } else {
            // End reach
            return Nil;
        }
    }
}

- (NSIndexPath*) getLastKPIbyDomain:(DCTechnologyId) theTechno {
    NSDictionary<NSString*,NSArray<KPI*>*> *theKPIDictionary = [self getKPIsPerDomain:theTechno];
    NSArray<NSString*> *sectionsHeader = [self getSectionsHeader:theTechno];
    NSArray<KPI*> *sectionContent = theKPIDictionary[sectionsHeader[(sectionsHeader.count - 1)]];
    
    return  [KPIDictionary indexPathForRow:(sectionContent.count-1) inSection:(sectionsHeader.count -1)];

}

- (KPI*) getKPIbyDomain:(NSIndexPath*) index  techno:(DCTechnologyId) theTechno{
    NSDictionary<NSString*,NSArray<KPI*>*> *theKPIDictionary = [self getKPIsPerDomain:theTechno];
    NSArray<NSString*> *sectionsHeader = [self getSectionsHeader:theTechno];
    NSArray<KPI*> *sectionContent = theKPIDictionary[sectionsHeader[[KPIDictionary section:index]]];
    
    KPI* cellKPI = sectionContent[[KPIDictionary row:index]];
    return cellKPI;
}


- (NSArray<NSString*>*) getSectionsHeader:(DCTechnologyId) theTechno {
    NSDictionary<NSString*,NSArray<KPI*>*> *KPIDictionary = [self getKPIsPerDomain:theTechno];
    NSArray<NSString*>* sectionsHeader = [KPIDictionary allKeys];
    return [sectionsHeader sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];

}

#pragma mark - Create KPI Dictionary

//KPI dictionary structure:
//KPIDictionaries[x].name = name of the dictionary
//KPIDictionaries[x].descripton = description of the dictionary
//KPIDictionaries[x].KPIs[y].techno = Tehcnology of the KPIs
//KPIDictionaries[x].KPIs[y].KPIs[z].name = external name of the KPI
//KPIDictionaries[x].KPIs[y].KPIs[z].internalName
//KPIDictionaries[x].KPIs[y].KPIs[z].shortDescription
//KPIDictionaries[x].KPIs[y].KPIs[z].domain
//KPIDictionaries[x].KPIs[y].KPIs[z].formula
//KPIDictionaries[x].KPIs[y].KPIs[z].unit
//KPIDictionaries[x].KPIs[y].KPIs[z].direction
//KPIDictionaries[x].KPIs[y].KPIs[z].low
//KPIDictionaries[x].KPIs[y].KPIs[z].medium
//KPIDictionaries[x].KPIs[y].KPIs[z].high
//KPIDictionaries[x].KPIs[y].KPIs[z].relatedKPI

+ (Boolean) loadKPIsdictionaries:(id) theData {
    NSArray* data = theData;

    if (data == Nil) {
        return false;
    }
    
    KPIDictionaryManager* dataCenterInstance = [KPIDictionaryManager sharedInstance];
    for (NSDictionary* theKPIDictionary in data) {
        KPIDictionary* currentDictionary = [[KPIDictionary alloc] init:theKPIDictionary[@"name"] description:theKPIDictionary[@"description"]];
        
        NSArray* allKPIsOfCurrentDictionary = theKPIDictionary[@"KPIs"];
        
        
        for (NSDictionary* currentKPIs in allKPIsOfCurrentDictionary) {
            NSString* currentTechno = currentKPIs[@"techno"];
            NSArray* KPIsForCurrentTechno = currentKPIs[@"KPIs"];
            
            for (NSDictionary* theKPI in KPIsForCurrentTechno) {
                KPI* newKPI = [[KPI alloc] init:theKPI techno:currentTechno];
                [currentDictionary addKPI:newKPI];
            }
        }
        
        [dataCenterInstance addKPIDictionary:currentDictionary];
    }
    
    return TRUE;
}

- (id) init:(NSString *) name description:(NSString*) theDescription {
    if (self = [super init]) {
        _name = name;
        _theDescription = theDescription;
        
        _lteKPIs = [[NSMutableArray alloc] init];
        _lteKPIsPerDomain = [[NSMutableDictionary alloc] init];
        
        _wcdmaKPIs = [[NSMutableArray alloc] init];
        _wcdmaKPIsPerDomain = [[NSMutableDictionary alloc] init];
        
        _gsmKPIs = [[NSMutableArray alloc] init];
        _gsmKPIsPerDomain = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}


- (void) addKPI:(KPI*) theKPI {
    
    switch (theKPI.technology) {
        case DCTechnologyLTE: {
            [self.lteKPIs addObject:theKPI];
            NSMutableArray<KPI*>* currDomainList = self.lteKPIsPerDomain[theKPI.domain];
            if (currDomainList == Nil) {
                currDomainList =[[NSMutableArray alloc] init];
                
                self.lteKPIsPerDomain[theKPI.domain] = currDomainList;
            }
            [currDomainList addObject:theKPI];
            break;
        }
        case DCTechnologyWCDMA: {
            [self.wcdmaKPIs addObject:theKPI];
            NSMutableArray<KPI*>* currDomainList = self.wcdmaKPIsPerDomain[theKPI.domain];
            if (currDomainList == Nil) {
                currDomainList =[[NSMutableArray alloc] init];
                
                self.wcdmaKPIsPerDomain[theKPI.domain] = currDomainList;
            }
            [currDomainList addObject:theKPI];
            break;
        }
        case DCTechnologyGSM: {
            [self.gsmKPIs addObject:theKPI];
            NSMutableArray<KPI*>* currDomainList = self.gsmKPIsPerDomain[theKPI.domain];
            if (currDomainList == Nil) {
                currDomainList =[[NSMutableArray alloc] init];
                
                self.gsmKPIsPerDomain[theKPI.domain] = currDomainList;
            }
            [currDomainList addObject:theKPI];
            break;
        }
        default: {
            NSLog(@"KPIDictionary::addKPI => Error, unknown techno for KPI");
        }
    }
}


@end
