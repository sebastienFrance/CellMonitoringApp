//
//  iMonMailContentActivity.h
//  iMonitoring
//
//  Created by sébastien brugalières on 01/10/13.
//
//

#import <Foundation/Foundation.h>

@interface iMonMailContentActivity : NSObject <UIActivityItemSource>


- (id) initWithData:(NSString*) HTMLMailContent;

@end
