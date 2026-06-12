//
//  HelloWorldScene.h
//  Woo Woo The Game
//
//  Created by Andrea Murru on 04/08/14.
//  Copyright Andrea Murru 2014. All rights reserved.
//
// -----------------------------------------------------------------------

// Importing cocos2d.h and cocos2d-ui.h, will import anything you need to start using Cocos2D v3
#import "cocos2d.h"
#import "cocos2d-ui.h"
#import "MammaSprite.h"
#import "PlayerSprite.h"
#import "GabbianoSprite.h"
#import "LifeBarSprite.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>

// -----------------------------------------------------------------------

/**
 *  The main scene
 */

@interface MyScene2 : CCScene <UIAccelerometerDelegate, CCPhysicsCollisionDelegate> {
    //PlayerSprite *_player;
    MammaSprite *_mamma;
    GabbianoSprite *_gabbiano_test;
    LifeBarSprite *_lifeBar;
    CMMotionManager *_motionManager;
    BOOL isMoving;

    CGPoint playerVelocity;

    BOOL comeEraGirato;
    
    int mostri;
    int precX;
    int precY;
    
        int precDeltaX;
    float time;
    CCLabelTTF *scoreLabel;
    CCLabelTTF *timeLabel;
    CCPhysicsNode *_physicsWorld;

    CCRenderTexture* _rt;
    
    NSInteger punteggio;
    NSInteger colpi_mostro;
    
    CCLabelTTF *countdownLabel;
    CCSprite *pausa;
    int countTime;
    
    NSTimer *timer;
    
    NSDate *pauseStart, *previousFireDate;
    CCButton *riprendi;
    CCButton *esci;

    NSMutableArray *movableSprites;
    
    CCMotionStreak *streak;
    //CFMutableDictionaryRef map;

}

// -----------------------------------------------------------------------

+ (MyScene2 *)scene;
- (id)init;

// -----------------------------------------------------------------------

@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;

@end