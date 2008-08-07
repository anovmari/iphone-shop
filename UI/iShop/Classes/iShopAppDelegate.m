//
//  iShopAppDelegate.m
//  iShop
//
//  Created by Anton Maryanov on 8/4/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "iShopAppDelegate.h"


@implementation iShopAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize navController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	// Add the tab bar controller's current view as a subview of the window
	[window addSubview:tabBarController.view];
//	[window addSubview:navController.view];
}


/*
 Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}
*/

/*
 Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
*/


- (void)dealloc {
	[tabBarController release];
	[window release];
	[super dealloc];
}

@end

