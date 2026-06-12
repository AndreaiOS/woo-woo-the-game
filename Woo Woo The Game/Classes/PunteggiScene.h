//
//  PunteggiScene.h
//  Woo Woo The Game
//
//  Created by Andrea Murru on 05/08/14.
//  Copyright (c) 2014 Andrea Murru. All rights reserved.
//

// Importing cocos2d.h and cocos2d-ui.h, will import anything you need to start using cocos2d-v3
#import "cocos2d.h"
#import "cocos2d-ui.h"
#import <GameKit/GameKit.h>

@interface PunteggiScene : CCScene <GKGameCenterControllerDelegate>


// -----------------------------------------------------------------------

+ (PunteggiScene *)scene;
- (id)init;
-(void)showLeaderboardAndAchievements:(BOOL)shouldShowLeaderboard;

// -----------------------------------------------------------------------
@end
