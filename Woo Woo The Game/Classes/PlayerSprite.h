//
//  PlayerSprite.h
//  Woo Woo The Game
//
//  Created by Andrea Murru on 06/08/14.
//  Copyright (c) 2014 Andrea Murru. All rights reserved.
//
#import "cocos2d.h"
#import "cocos2d-ui.h"
#import "CCSprite.h"

@interface PlayerSprite : CCSprite {
    CCSprite *spriteName;
    CGPoint vel;
    CGPoint pos;
    BOOL isSinistra;
    int vita;
    
    CCSprite *sprite;
    NSMutableArray *pointArray;
    CGMutablePathRef path;
    
    BOOL primo;
    
    CCAction *camminaAction;
}
+ (PlayerSprite*)PlayerSprite;
@property (nonatomic, retain) CCSprite *_sprite;
@property (nonatomic, retain) NSMutableArray *pointArray;

-(void)createPath;
-(void)zacca_a_sinistra;
-(void)zacca_a_destra;
-(void)colpita;
-(void)cammina;
-(void)muore;
@end
