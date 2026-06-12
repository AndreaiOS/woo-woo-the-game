//
//  TutorialScene.m
//  Woo Woo The Game
//
//  Created by Andrea Murru on 13/08/14.
//  Copyright (c) 2014 Andrea Murru. All rights reserved.
//

#import "TutorialScene.h"
#import "MyScene.h"
#import "Singleton.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "AppDelegate.h"
#import "GAI.h"
#import "IntroScene.h"

@implementation TutorialScene

@synthesize pageControl;

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    
    if([singleton is_sound])
        [[OALSimpleAudio sharedInstance] playEffect:@"intro_02.mp3" loop:NO];

    self.userInteractionEnabled = TRUE;

    background = [CCSprite spriteWithTexture:nil rect:CGRectMake(0, 0, self.contentSize.width * 5, self.contentSize.height)];
    background.position = CGPointMake(self.contentSize.width * 2, 0);
    [self addChild:background];
    //background.userInteractionEnabled = true;
    tutorial1 = [CCSprite spriteWithImageNamed:@"tutorial01_iPhone.png"];
    [tutorial1 setColor:[CCColor colorWithCcColor3b:ccc3(200, 200, 200)]];
    tutorial1.position  = ccp((self.contentSize.width) * 1,self.contentSize.height);
    [background addChild:tutorial1];
    
    tutorial2 = [CCSprite spriteWithImageNamed:@"tutorial02_iPhone.png"];
    [tutorial2 setColor:[CCColor colorWithCcColor3b:ccc3(200, 200, 200)]];
    tutorial2.position  = ccp(self.contentSize.width * 2,self.contentSize.height);
    [background addChild:tutorial2];
    
    tutorial3 = [CCSprite spriteWithImageNamed:@"tutorial03_iPhone.png"];
    [tutorial3 setColor:[CCColor colorWithCcColor3b:ccc3(200, 200, 200)]];
    tutorial3.position  = ccp(self.contentSize.width * 3,self.contentSize.height);
    [background addChild:tutorial3];
    
    tutorial4 = [CCSprite spriteWithImageNamed:@"tutorial04_iPhone.png"];
    [tutorial4 setColor:[CCColor colorWithCcColor3b:ccc3(200, 200, 200)]];
    tutorial4.position  = ccp((self.contentSize.width) * 4,self.contentSize.height);
    [background addChild:tutorial4];
    
    tutorial5 = [CCSprite spriteWithImageNamed:@"tutorial05_iPhone.png"];
    [tutorial5 setColor:[CCColor colorWithCcColor3b:ccc3(200, 200, 200)]];
    tutorial5.position  = ccp((self.contentSize.width) * 5,self.contentSize.height);
    [background addChild:tutorial5];
    
    CCButton *startGame = [CCButton buttonWithTitle:@"Start" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_label.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_label.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_label.png"]];
    startGame.label.fontColor = [CCColor blackColor];
    startGame.label.fontSize = 28;
    startGame.label.fontName = @"Moon Flower Bold";
    startGame.positionType = CCPositionTypeNormalized;
    startGame.position = ccp(0.80f, 0.10f);
    [startGame setTarget:self selector:@selector(start_game)];
    [self addChild:startGame];
    
    CCButton *close = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_chiudi.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_chiudi.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_chiudi.png"]];
    close.togglesSelectedState = true;
    close.positionType = CCPositionTypeNormalized;
    close.position = ccp(0.10f, 0.90f);
    [close setTarget:self selector:@selector(checkClose)];
    [self addChild:close];
    
    pagina = 0;
    /*
    lblPunteggio = [[CCLabelTTF alloc] init];
    lblPunteggio = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"1/5"] fontName:@"Moon Flower Bold" fontSize:50];
    lblPunteggio.fontColor = [CCColor colorWithUIColor:[UIColor whiteColor]];
    lblPunteggio.positionType = CCPositionTypeNormalized;
    lblPunteggio.position = ccp(0.50f,0.10f);
    [self addChild:lblPunteggio];
    */
    
    pageControl = [[UIPageControl alloc] init];
    pageControl.frame = CGRectMake(self.contentSize.height / 2 , 270, 100, 50);
    pageControl.numberOfPages = 5;
    pageControl.currentPage = 0;
    [[[CCDirector sharedDirector] view] addSubview:pageControl];
    //[self addChild:pageControl];
    
    // Returns t1.
    id<GAITracker> defaultTracker = [[GAI sharedInstance] defaultTracker];
    
    // Hit sent to UA-XXXX-1.
    [defaultTracker send:[[[GAIDictionaryBuilder createAppView]
                           set:@"Tutorial Screen" forKey:kGAIScreenName] build]];
    return self;
}

+ (TutorialScene *)scene
{
	return [[self alloc] init];
}

-(void)start_game {
    [pageControl setHidden:true];

    
    [[OALSimpleAudio sharedInstance] stopAllEffects];

    [[CCDirector sharedDirector] replaceScene:[MyScene scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:0.7f]];
    
}

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    //return TRUE;
    mono_movimento = true;

}

-(void) touchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    if(mono_movimento == true) {
    CGPoint touchLoc = [touch locationInNode:self];
    
    CGPoint oldTouchLocation = [touch previousLocationInView:touch.view];
    oldTouchLocation = [[CCDirector sharedDirector] convertToGL:oldTouchLocation];
    oldTouchLocation = [self convertToNodeSpace:oldTouchLocation];
    //NSLog([NSString stringWithFormat:@"%f", self.contentSize.width]);

    
    //CGPoint translation = ccpSub(touchLoc, oldTouchLocation);
    double movimento = oldTouchLocation.x - touchLoc.x;
    if(movimento < 0) {
        //if(pagina > 0)
            //pagina--;
        //CCActionMoveTo *actionMoveLeft = [CCActionMoveTo actionWithDuration:0.5f position:CGPointMake((self.contentSize.width / 2),0)];
        //[background runAction:actionMoveLeft];
    } else {
        if (pagina < 6) {
            pagina++;
            [self gestisci_pagina];

            //long position = self.contentSize.width * (pagina / 2);
            //CCActionMoveTo *actionMoveLeft = [CCActionMoveTo actionWithDuration:0.5f position:CGPointMake(position,0)];
            //[background runAction:actionMoveLeft];
            //CCActionMoveTo *actionMoveLeft = [CCActionMoveTo actionWithDuration:0.5f position:CGPointMake(-(self.contentSize.width / 2),0)];
            //[background runAction:actionMoveLeft];
        }
    }
        mono_movimento = false;
        
        //[lblPunteggio setString:[NSString stringWithFormat:@"%d/5", pagina+1]];
        pageControl.currentPage = pagina;

        
    }
    else {
        
    }
}

-(void)gestisci_pagina {
    switch (pagina) {
        /*case 0: {
            CCActionMoveTo *actionMoveLeft = [CCActionMoveTo actionWithDuration:0.5f position:CGPointMake((self.contentSize.width) * 1,0)];
            [background runAction:actionMoveLeft];
            break;
        }*/
        case 1: {
            CCActionMoveTo *actionMoveLeft = [CCActionMoveTo actionWithDuration:0.5f position:CGPointMake(self.contentSize.width,0)];
            [background runAction:actionMoveLeft];
            break;
        }
        case 2: {
            CCActionMoveTo *actionMoveLeft = [CCActionMoveTo actionWithDuration:0.5f position:CGPointMake(0,0)];
            [background runAction:actionMoveLeft];
            break;
        }
        case 3: {
            CCActionMoveTo *actionMoveLeft = [CCActionMoveTo actionWithDuration:0.5f position:CGPointMake(-(self.contentSize.width),0)];
            [background runAction:actionMoveLeft];
            break;
        }
        case 4: {
            CCActionMoveTo *actionMoveLeft = [CCActionMoveTo actionWithDuration:0.5f position:CGPointMake(-(self.contentSize.width) * 2,0)];
            [background runAction:actionMoveLeft];
            break;
        }
        case 5: {
            [self start_game];
            break;
        }
        default:
            break;
    }

}

-(void)checkClose {
    [[OALSimpleAudio sharedInstance] stopAllEffects];

    [pageControl setHidden:true];
    [[CCDirector sharedDirector] replaceScene:[IntroScene scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionRight duration:0.1F]];
}
@end
