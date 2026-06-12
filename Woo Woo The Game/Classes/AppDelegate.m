//
//  AppDelegate.m
//  Woo Woo The Game
//
//  Created by Andrea Murru on 04/08/14.
//  Copyright Andrea Murru 2014. All rights reserved.
//
// -----------------------------------------------------------------------

#import "AppDelegate.h"
#import "IntroScene.h"
#import "MyScene.h"
#import "Singleton.h"
#import "GAI.h"

@implementation AppDelegate

//
-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// This is the only app delegate method you need to implement when inheriting from CCAppDelegate.
	// This method is a good place to add one time setup code that only runs when your app is first launched.
	
	// Setup Cocos2D with reasonable defaults for everything.
	// There are a number of simple options you can change.
	// If you want more flexibility, you can configure Cocos2D yourself instead of calling setupCocos2dWithOptions:.
	[self setupCocos2dWithOptions:@{
		// Show the FPS and draw call label.
		CCSetupShowDebugStats: @(YES),
		
		// More examples of options you might want to fiddle with:
		// (See CCAppDelegate.h for more information)
		
		// Use a 16 bit color buffer: 
//		CCSetupPixelFormat: kEAGLColorFormatRGB565,
		// Use a simplified coordinate system that is shared across devices.
//		CCSetupScreenMode: CCScreenModeFixed,
		// Run in portrait mode.
//		CCSetupScreenOrientation: CCScreenOrientationPortrait,
		// Run at a reduced framerate.
//		CCSetupAnimationInterval: @(1.0/30.0),
		// Run the fixed timestep extra fast.
//		CCSetupFixedUpdateInterval: @(1.0/180.0),
		// Make iPad's act like they run at a 2x content scale. (iPad retina 4x)
//		CCSetupTabletScale2X: @(YES),
	}];
	
    //[singleton cambia_audio:1];
    //[singleton cambia_sound:1];
    //[singleton cambia_vibro:1];
    

    
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-45709984-3"];
    
    //[self setMultipleTouchEnabled:TRUE];

    
	return YES;
}

-(CCScene *)startScene
{
	// This method should return the very first scene to be run when your app starts.
	return [IntroScene scene];
}

- (void) applicationDidFinishLaunching:(UIApplication*)application
{

}


- (void)applicationWillResignActive:(UIApplication *)application {
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[CCDirector sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	CCDirector *director = [CCDirector sharedDirector];
	
	[director end];
}



@end
