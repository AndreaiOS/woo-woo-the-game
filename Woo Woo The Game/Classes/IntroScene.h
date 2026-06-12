//
//  IntroScene.h
//  Woo Woo The Game
//
//  Created by Andrea Murru on 04/08/14.
//  Copyright Andrea Murru 2014. All rights reserved.
//
// -----------------------------------------------------------------------

// Importing cocos2d.h and cocos2d-ui.h, will import anything you need to start using cocos2d-v3
#import "cocos2d.h"
#import "cocos2d-ui.h"
#import <GameKit/GameKit.h>


// -----------------------------------------------------------------------

/**
 *  The intro scene
 *  Note, that scenes should now be based on CCScene, and not CCLayer, as previous versions
 *  Main usage for CCLayer now, is to make colored backgrounds (rectangles)
 *
 */
@interface IntroScene : CCScene {
    CCButton *audio;
    CCButton *sound;
    CCButton *vibro;
    CCButton *info;

}

// -----------------------------------------------------------------------

+ (IntroScene *)scene;
- (id)init;
-(void)authenticateLocalPlayer;


// -----------------------------------------------------------------------


@end