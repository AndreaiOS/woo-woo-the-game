//
//  TutorialScene.h
//  Woo Woo The Game
//
//  Created by Andrea Murru on 13/08/14.
//  Copyright (c) 2014 Andrea Murru. All rights reserved.
//

#import "cocos2d.h"
#import "cocos2d-ui.h"

@interface TutorialScene : CCScene  {
    CCSprite *tutorial1;
    CCSprite *tutorial2;
    CCSprite *tutorial3;
    CCSprite *tutorial4;
    CCSprite *tutorial5;
    CCSprite *background;
    
    int pagina;
    
    BOOL mono_movimento;
    
    //CCLabelTTF *lblPunteggio;
}
+ (TutorialScene *)scene;
- (id)init;

@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;

@end
