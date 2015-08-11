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

-(void) startHelp:(UIViewController*) controller;
-(void) startHelpWithoutLogin:(UIViewController*) controller;

-(void) helpForGenericGraphicKPI:(UIViewController*) controller;
-(void) iPadHelpForDashboardView:(UIViewController*) controller;
-(void) iPadHelpForCellDashboardView:(UIViewController*) controller;

@end
