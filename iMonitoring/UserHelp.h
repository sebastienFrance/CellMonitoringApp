//
//  UserHelp.h
//  CellMonitoring
//
//  Created by sébastien brugalières on 07/04/2014.
//
//

#import <Foundation/Foundation.h>

@interface UserHelp : NSObject

+ (UserHelp*) sharedInstance;

-(void) startHelp;
-(void) startHelpWithoutLogin;

-(void) helpForGenericGraphicKPI;
-(void) iPadHelpForDashboardView;
-(void) iPadHelpForCellDashboardView;

@end
