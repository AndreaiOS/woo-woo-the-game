//
//  LifeBarSprite.h
//  Woo Woo The Game
//
//  Created by Andrea Murru on 07/08/14.
//  Copyright (c) 2014 Andrea Murru. All rights reserved.
//

#import "cocos2d.h"
#import "cocos2d-ui.h"
#import "CCSprite.h"

@interface LifeBarSprite : CCSprite
+ (LifeBarSprite*)LifeBarSprite;
-(void)set_vita:(long)vita;
@end
