//
//  GabbianoSprite.h
//  Woo Woo The Game
//
//  Created by Andrea Murru on 06/08/14.
//  Copyright (c) 2014 Andrea Murru. All rights reserved.
//

#import "cocos2d.h"
#import "cocos2d-ui.h"
#import "CCSprite.h"

@interface GabbianoSprite : CCSprite {
    int precX;
    int precY;
    int vita;
    NSNumber *isAmico;
    NSNumber *isBonus;

    CCActionInterval *animateActionVola;
}
+ (GabbianoSprite*)GabbianoSprite;
+ (GabbianoSprite*)GabbianoSpriteAmico;
-(void)vola;
-(void)volaAmico;
//-(void)volaSx;
-(void)fuoco;
-(void)muore;
-(void)setAmico:(NSNumber*)amico;
-(NSNumber*)returnAmico;
-(void)setBonus:(NSNumber*)bonus;
-(NSNumber*)returnBonus;
@end
