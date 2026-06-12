//
//  LifeBarSprite.m
//  Woo Woo The Game
//
//  Created by Andrea Murru on 07/08/14.
//  Copyright (c) 2014 Andrea Murru. All rights reserved.
//

#import "LifeBarSprite.h"

@implementation LifeBarSprite
+ (LifeBarSprite*)LifeBarSprite
{
    LifeBarSprite * lifeBarSprite = [[LifeBarSprite alloc] initWithImageNamed:@"lifebar-01.png"];
    return lifeBarSprite;
}

-(void)set_vita:(long)vita {
    
    switch (vita) {
        case 0: {
            CCSpriteFrame *frame = [CCSpriteFrame frameWithImageNamed:@"lifebar-01.png"];
            [self setTexture:[[CCSprite spriteWithSpriteFrame:frame]texture]];
            break;
        }
        case 1: {
            CCSpriteFrame *frame = [CCSpriteFrame frameWithImageNamed:@"lifebar-02.png"];
            [self setTexture:[[CCSprite spriteWithSpriteFrame:frame]texture]];
            break;
        }
        case 2: {
            CCSpriteFrame *frame = [CCSpriteFrame frameWithImageNamed:@"lifebar-03.png"];
            [self setTexture:[[CCSprite spriteWithSpriteFrame:frame]texture]];
            break;
        }
        case 3: {
            CCSpriteFrame *frame = [CCSpriteFrame frameWithImageNamed:@"lifebar-04.png"];
            [self setTexture:[[CCSprite spriteWithSpriteFrame:frame]texture]];
            break;
        }
        case 4: {
            CCSpriteFrame *frame = [CCSpriteFrame frameWithImageNamed:@"lifebar-05.png"];
            [self setTexture:[[CCSprite spriteWithSpriteFrame:frame]texture]];
            break;
        }
        case 5: {
            CCSpriteFrame *frame = [CCSpriteFrame frameWithImageNamed:@"lifebar-06.png"];
            [self setTexture:[[CCSprite spriteWithSpriteFrame:frame]texture]];
            break;
        }
        case 6: {
            CCSpriteFrame *frame = [CCSpriteFrame frameWithImageNamed:@"lifebar-07.png"];
            [self setTexture:[[CCSprite spriteWithSpriteFrame:frame]texture]];
            break;
        }
        case 7: {
            CCSpriteFrame *frame = [CCSpriteFrame frameWithImageNamed:@"lifebar-08.png"];
            [self setTexture:[[CCSprite spriteWithSpriteFrame:frame]texture]];
            break;
        }
        case 8: {
            CCSpriteFrame *frame = [CCSpriteFrame frameWithImageNamed:@"lifebar-09.png"];
            [self setTexture:[[CCSprite spriteWithSpriteFrame:frame]texture]];
            break;
        }
        case 9: {
            CCSpriteFrame *frame = [CCSpriteFrame frameWithImageNamed:@"lifebar-10.png"];
            [self setTexture:[[CCSprite spriteWithSpriteFrame:frame]texture]];
            break;
        }
            
     default:
            break;
    }

    //CCSpriteFrame *frame = [CCSpriteFrame frameWithImageNamed:@"lifebar-01.png"];
    //[self setTexture:[[CCSprite spriteWithSpriteFrame:frame]texture]];

    

}
@end
