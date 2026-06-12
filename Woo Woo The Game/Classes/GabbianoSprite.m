//
//  GabbianoSprite.m
//  Woo Woo The Game
//
//  Created by Andrea Murru on 06/08/14.
//  Copyright (c) 2014 Andrea Murru. All rights reserved.
//

#import "GabbianoSprite.h"
#import "CCDirector.h"
#import "CCSpriteFrameCache.h"
#import "CCAnimation.h"
#import "CCAction.h"

@implementation GabbianoSprite
+ (GabbianoSprite*)GabbianoSprite
{
    GabbianoSprite * gabbianoSprite = [[GabbianoSprite alloc] initWithImageNamed:@"gabbiano-zampeVola01-hd.png"];
    
    return gabbianoSprite;
}

+ (GabbianoSprite*)GabbianoSpriteAmico
{
    GabbianoSprite * gabbianoSprite = [[GabbianoSprite alloc] initWithImageNamed:@"gabbiano-zampeVola01-hd.png"];
    
    return gabbianoSprite;
}

-(void)vola {
    vita = 2;
    
    NSMutableArray *frames = [NSMutableArray array];
    
    //int frameCount = 0;
    
    for (int i = 1; i <= 8; i++) {
        CCSpriteFrame *frame = [CCSpriteFrame frameWithImageNamed:[NSString stringWithFormat:@"gabbiano-zampeVola0%d.png",i]];
        
        [frames addObject:frame];
    }
    [self setFlipX:false];

    [self setScale:1.4f];
    CCAnimation *animation = [CCAnimation animationWithSpriteFrames:frames delay:0.05];
    animateActionVola = [CCActionAnimate actionWithAnimation:animation];
    [animateActionVola setTag:7];
    //animateActionVola.tag = 7;
    CCActionRepeatForever *repeat=[CCActionRepeatForever actionWithAction:animateActionVola];
    [repeat setTag:5];
    [self runAction: repeat];
}

-(void)volaAmico {
    vita = 2;
    
    NSMutableArray *frames = [NSMutableArray array];
    
    //int frameCount = 0;
    
    for (int i = 1; i <= 8; i++) {
        CCSpriteFrame *frame = [CCSpriteFrame frameWithImageNamed:[NSString stringWithFormat:@"gabbiano-zampeVola0%d.png",i]];
        [frames addObject:frame];
    }
    //[self setFlipX:false];
    
    [self setFlipY:true];

    
    [self setScale:1.4f];
    CCAnimation *animation = [CCAnimation animationWithSpriteFrames:frames delay:0.05];
    animateActionVola = [CCActionAnimate actionWithAnimation:animation];
    [animateActionVola setTag:7];
    //animateActionVola.tag = 7;
    CCActionRepeatForever *repeat=[CCActionRepeatForever actionWithAction:animateActionVola];
    [repeat setTag:5];
    [self runAction: repeat];
}

-(void)fuoco {
    //[self stopAllActions];
    
    NSMutableArray *frames = [NSMutableArray array];
    
    for (int i = 1; i <= 8; i++) {
        CCSpriteFrame *frame = [CCSpriteFrame frameWithImageNamed:[NSString stringWithFormat:@"gabbiano-zampeVola0%dMuore.png",i]];

        [frames addObject:frame];
    }
    
    while ([self getActionByTag:7]) {
        [self stopActionByTag:7];
    };
    
    while ([self getActionByTag:5]) {
        [self stopActionByTag:5];
    };

    self.physicsBody.collisionType  = @"fuocoCollision";

    CCAnimation *animation = [CCAnimation animationWithSpriteFrames:frames delay:0.05];

    CCActionAnimate *animateActionBrucia = [CCActionAnimate actionWithAnimation:animation];

    animateActionBrucia.tag = 8;
    [self runAction: [CCActionRepeatForever actionWithAction:animateActionBrucia]];


}

-(void)muore {
    NSMutableArray *frames = [NSMutableArray array];
    
    CCSpriteFrame *frame = [CCSpriteFrame frameWithImageNamed:[NSString stringWithFormat:@"gabbiano-zampeMuore.png"]];
        
    [frames addObject:frame];
        CCAnimation *animation = [CCAnimation animationWithSpriteFrames:frames delay:0.15];
    CCAction *animateAction = [CCActionAnimate actionWithAnimation:animation];
    
    self.physicsBody.collisionType  = @"gabbianoMortoCollision";
    //Devo gestire la collisione mentre muore
    
    CCActionCallBlock *actionAfterMoving = [CCActionCallBlock actionWithBlock:^{
        [self removeFromParentAndCleanup:true];
    }];
    
    CCActionSequence *movingSequeceAndOtherStuffAfter = [CCActionSequence actionWithArray:@[animateAction, actionAfterMoving]];
    [self runAction:movingSequeceAndOtherStuffAfter];
}

-(void)setAmico:(NSNumber*)amico {
    isAmico = amico;
}

-(NSNumber*)returnAmico {
    return isAmico;
}

-(void)setBonus:(NSNumber*)bonus {
    isBonus = bonus;
}

-(NSNumber*)returnBonus {
    return isBonus;
}

@end
