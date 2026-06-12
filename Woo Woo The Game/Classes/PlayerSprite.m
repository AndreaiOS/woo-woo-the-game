//
//  PlayerSprite.m
//  Woo Woo The Game
//
//  Created by Andrea Murru on 06/08/14.
//  Copyright (c) 2014 Andrea Murru. All rights reserved.
//

#import "PlayerSprite.h"
#import "CCSpriteFrameCache.h"
#import "CCAnimation.h"
#import "CCAction.h"



@implementation PlayerSprite
+ (PlayerSprite*)PlayerSprite
{
    PlayerSprite * playerSprite = [[PlayerSprite alloc] initWithImageNamed:@"figlia_cammina01.png"];
    


    
    return playerSprite;
}


-(void)zacca_a_sinistra {
    [self stopAllActions];
    [self cammina];
    
    NSMutableArray *frames = [NSMutableArray array];

    //int frameCount = 0;
    
    for (int i = 1; i <= 7; i++) {
        CCSpriteFrame *frame = [CCSpriteFrame frameWithImageNamed:[NSString stringWithFormat:@"figlia_colpisce0%d.png",i]];

        [frames addObject:frame];
    }
    //
//        self.scaleX = 1;
    [self setFlipX:false];

    if(isSinistra!=true) {
        [self setPosition:CGPointMake(self.position.x - 30, self.position.y)];
        
        CGFloat offsetXPlayer = self.contentSize.width * self.anchorPoint.x - (self.contentSize.width / 2) ;
        CGFloat offsetYPlayer = self.contentSize.height * self.anchorPoint.y - (self.contentSize.height / 2);
        
        CGPoint puntoFiglia1 = CGPointMake(95  - offsetXPlayer, 119 - offsetYPlayer);
        CGPoint puntoFiglia2 = CGPointMake(120 - offsetXPlayer, 117 - offsetYPlayer);
        CGPoint puntoFiglia3 = CGPointMake(143 - offsetXPlayer, 52  - offsetYPlayer);
        CGPoint puntoFiglia4 = CGPointMake(144 - offsetXPlayer, 0   - offsetYPlayer);
        CGPoint puntoFiglia5 = CGPointMake(51  - offsetXPlayer, 0   - offsetYPlayer);
        CGPoint puntoFiglia6 = CGPointMake(47  - offsetXPlayer, 49  - offsetYPlayer);
        CGPoint puntoFiglia7 = CGPointMake(75  - offsetXPlayer, 115 - offsetYPlayer);
        
        CGPoint figliaPoints[] = {
            puntoFiglia1, puntoFiglia2, puntoFiglia3, puntoFiglia4, puntoFiglia5, puntoFiglia6, puntoFiglia7}
        ;
        
        self.physicsBody = [CCPhysicsBody bodyWithPolygonFromPoints:figliaPoints count:7 cornerRadius:3.0];

    }
    self.physicsBody.collisionType  = @"colpiCollision";

    CCAnimation *animation = [CCAnimation animationWithSpriteFrames:frames delay:0.05];
    CCAction *animateAction = [CCActionAnimate actionWithAnimation:animation];
    //[self runAction:animateAction];
    
    CCActionCallBlock *actionAfterMoving = [CCActionCallBlock actionWithBlock:^{
        self.physicsBody.collisionType  = @"playerCollision";
    }];
    CCActionSequence *movingSequeceAndOtherStuffAfter = [CCActionSequence actionWithArray:@[animateAction, actionAfterMoving]];
    [self runAction:movingSequeceAndOtherStuffAfter];
    
    isSinistra = true;

}

-(void)zacca_a_destra {
    [self stopAllActions];
    [self cammina];
    
    NSMutableArray *frames = [NSMutableArray array];
    
    //int frameCount = 0;
    
    for (int i = 1; i <= 7; i++) {
        CCSpriteFrame *frame = [CCSpriteFrame frameWithImageNamed:[NSString stringWithFormat:@"figlia_colpisce0%d.png",i]];
        
        
        [frames addObject:frame];
    }
//    if(isSinistra!=false)
    [self setFlipX:true];
    
    if(isSinistra!=false) {
        [self setPosition:CGPointMake(self.position.x + 30, self.position.y)];
        
        CGFloat offsetXPlayer = self.contentSize.width * self.anchorPoint.x - (self.contentSize.width / 2) + 30;
        CGFloat offsetYPlayer = self.contentSize.height * self.anchorPoint.y - (self.contentSize.height / 2);
        
        CGPoint puntoFiglia1 = CGPointMake(95  - offsetXPlayer, 119 - offsetYPlayer);
        CGPoint puntoFiglia2 = CGPointMake(120 - offsetXPlayer, 117 - offsetYPlayer);
        CGPoint puntoFiglia3 = CGPointMake(143 - offsetXPlayer, 52  - offsetYPlayer);
        CGPoint puntoFiglia4 = CGPointMake(144 - offsetXPlayer, 0   - offsetYPlayer);
        CGPoint puntoFiglia5 = CGPointMake(51  - offsetXPlayer, 0   - offsetYPlayer);
        CGPoint puntoFiglia6 = CGPointMake(47  - offsetXPlayer, 49  - offsetYPlayer);
        CGPoint puntoFiglia7 = CGPointMake(75  - offsetXPlayer, 115 - offsetYPlayer);
        
        CGPoint figliaPoints[] = {
            puntoFiglia1, puntoFiglia2, puntoFiglia3, puntoFiglia4, puntoFiglia5, puntoFiglia6, puntoFiglia7}
        ;
        
        self.physicsBody = [CCPhysicsBody bodyWithPolygonFromPoints:figliaPoints count:7 cornerRadius:3.0];
        //self.physicsBody.collisionType  = @"playerCollision";

    }
    
    self.physicsBody.collisionType  = @"colpiCollision";
    
    CCAnimation *animation = [CCAnimation animationWithSpriteFrames:frames delay:0.05];
    CCAction *animateAction = [CCActionAnimate actionWithAnimation:animation];
    //[self runAction:animateAction];
    
    CCActionCallBlock *actionAfterMoving = [CCActionCallBlock actionWithBlock:^{
        self.physicsBody.collisionType  = @"playerCollision";
    }];
    CCActionSequence *movingSequeceAndOtherStuffAfter = [CCActionSequence actionWithArray:@[animateAction, actionAfterMoving]];
    [self runAction:movingSequeceAndOtherStuffAfter];
    
    isSinistra = false;

}

-(void)cammina {
    //[self addPoints];
    //[self createPath];
    
    vita = 10;
    if(!primo) {
        primo = true;
        isSinistra = true;
    }
    
    NSMutableArray *frames = [NSMutableArray array];
    
    //int frameCount = 0;
    
    for (int i = 1; i <= 5; i++) {
        CCSpriteFrame *frame = [CCSpriteFrame frameWithImageNamed:[NSString stringWithFormat:@"figlia_cammina0%d.png",i]];
        
        [frames addObject:frame];
    }
    
    //CCSprite *sprite = [CCSprite spriteWithSpriteFrame:frames.firstObject];
    //[self removeAllChildren];

    //[self addChild:sprite]; // or to whatever object it will be parented to
    //
    
    //self.position = ccp(100.0, 105.0);
    
    CCAnimation *animation = [CCAnimation animationWithSpriteFrames:frames delay:0.05];
    camminaAction = [CCActionAnimate actionWithAnimation:animation];

    [self runAction: [CCActionRepeatForever actionWithAction:camminaAction]];
}

-(void)colpita {
    //isSinistra = true;
    
    NSMutableArray *frames = [NSMutableArray array];
    
    //int frameCount = 0;
    
    for (int i = 1; i <= 5; i++) {
        CCSpriteFrame *frame = [CCSpriteFrame frameWithImageNamed:[NSString stringWithFormat:@"figlia_colpita0%d.png",i]];
        
        [frames addObject:frame];
    }
    
    /*
    if(isSinistra!=false) {
        [self setPosition:CGPointMake(self.position.x + 30, self.position.y)];
    } else {
        [self setPosition:CGPointMake(self.position.x - 30, self.position.y)];
    }
    */
    self.physicsBody.collisionType  = @"colpitaCollision";
    
    CCAnimation *animation = [CCAnimation animationWithSpriteFrames:frames delay:0.05];
    CCAction *animateAction = [CCActionAnimate actionWithAnimation:animation];
    //[self runAction:animateAction];
    
    CCActionCallBlock *actionAfterMoving = [CCActionCallBlock actionWithBlock:^{
        self.physicsBody.collisionType  = @"playerCollision";
    }];
    CCActionSequence *movingSequeceAndOtherStuffAfter = [CCActionSequence actionWithArray:@[animateAction, actionAfterMoving]];
    [self runAction:movingSequeceAndOtherStuffAfter];

}

-(void)muore {
    
    [self stopAction:camminaAction];

    isSinistra = true;
    
    NSMutableArray *frames = [NSMutableArray array];
    
    //int frameCount = 0;
    
    for (int i = 1; i <= 9; i++) {
        CCSpriteFrame *frame = [CCSpriteFrame frameWithImageNamed:[NSString stringWithFormat:@"figlia_muore0%d.png",i]];
        
        [frames addObject:frame];
    }
    
    //CCSprite *sprite = [CCSprite spriteWithSpriteFrame:frames.firstObject];
    //[self removeAllChildren];
    
    //[self addChild:sprite]; // or to whatever object it will be parented to
    //
    
    //self.position = ccp(100.0, 105.0);
    
    CCAnimation *animation = [CCAnimation animationWithSpriteFrames:frames delay:0.10];
    CCAction *animateAction = [CCActionAnimate actionWithAnimation:animation];
    
    [self runAction:animateAction];
    
    
    //[self stopAllActions];

}




@end
