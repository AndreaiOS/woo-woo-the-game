//
//  GameOverSceneMamma.h
//  Woo Woo The Game
//
//  Created by Andrea Murru on 12/08/14.
//  Copyright (c) 2014 Andrea Murru. All rights reserved.
//

#import "cocos2d.h"
#import "cocos2d-ui.h"
#import "GADInterstitial.h"
#import <GameKit/GameKit.h>

@interface GameOverSceneMamma : CCScene <GADInterstitialDelegate, GKGameCenterControllerDelegate> {
    NSInteger punteggio;
    GADInterstitial *interstitial_;
    UIActivityIndicatorView *spinner;

    CCButton *rigiocaBtn;
    CCButton *backButton;
    CCButton *punteggi;
    CCButton *medaglie;
    
    NSTimer *timer;
    float time;

}
+ (GameOverSceneMamma *)scene;
- (id)init;
-(void)reportScore;
-(void)updateAchievements;

@end
