//
//  MammaSprite.m
//  Woo Woo The Game
//
//  Created by Andrea Murru on 06/08/14.
//  Copyright (c) 2014 Andrea Murru. All rights reserved.
//

#import "MammaSprite.h"
#import "CCSpriteFrameCache.h"
#import "CCAnimation.h"
#import "CCAction.h"

@implementation MammaSprite

+ (MammaSprite*)MammaSprite
{
    MammaSprite * mammaSprite = [[MammaSprite alloc] initWithImageNamed:@"mamma_statica01.png"];
    
    
    return mammaSprite;
}

-(void)vive {
    
    NSMutableArray *frames = [NSMutableArray array];
    
    //int frameCount = 0;
    
    for (int i = 1; i <= 3; i++) {
        CCSpriteFrame *frame = [CCSpriteFrame frameWithImageNamed:[NSString stringWithFormat:@"mamma_statica0%d.png",i]];
        
        [frames addObject:frame];
    }
    
    //CCSprite *sprite = [CCSprite spriteWithSpriteFrame:frames.firstObject];
    //[self removeAllChildren];
    
    //[self addChild:sprite]; // or to whatever object it will be parented to
    //
    
    //self.position = CGPointMake(self.contentSize.width / 2, self.contentSize.height / 2);
    
    CCAnimation *animation = [CCAnimation animationWithSpriteFrames:frames delay:1.0];
    CCAction *animateAction = [CCActionAnimate actionWithAnimation:animation];
    
    [self runAction: [CCActionRepeatForever actionWithAction:animateAction]];
}

-(void)soffre {
    
    NSMutableArray *frames = [NSMutableArray array];
    
    //int frameCount = 0;
    
    for (int i = 1; i <= 2; i++) {
        CCSpriteFrame *frame = [CCSpriteFrame frameWithImageNamed:[NSString stringWithFormat:@"mamma_soffre0%d.png",i]];
        
        [frames addObject:frame];
    }
    
    //CCSprite *sprite = [CCSprite spriteWithSpriteFrame:frames.firstObject];
    //[self removeAllChildren];
    
    //[self addChild:sprite]; // or to whatever object it will be parented to
    //
    
    //self.position = ccp(100.0, 105.0);
    /*
    CCAnimation *animation = [CCAnimation animationWithSpriteFrames:frames delay:1.0];
    CCAction *animateAction = [CCActionAnimate actionWithAnimation:animation];
    
    [self runAction: [CCActionRepeatForever actionWithAction:animateAction]];
    */
    self.physicsBody.collisionType  = @"mammaColpitaCollision";
    
    CCAnimation *animation = [CCAnimation animationWithSpriteFrames:frames delay:1.0];
    CCAction *animateAction = [CCActionAnimate actionWithAnimation:animation];
    //[self runAction:animateAction];
    
    CCActionCallBlock *actionAfterMoving = [CCActionCallBlock actionWithBlock:^{
        self.physicsBody.collisionType  = @"mammaCollision";
    }];
    CCActionSequence *movingSequeceAndOtherStuffAfter = [CCActionSequence actionWithArray:@[animateAction, actionAfterMoving]];
    [self runAction:movingSequeceAndOtherStuffAfter];
}
@end
