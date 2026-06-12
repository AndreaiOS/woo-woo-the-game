//
//  PunteggiSceneMamma.m
//  Woo Woo The Game
//
//  Created by Andrea Murru on 05/08/14.
//  Copyright (c) 2014 Andrea Murru. All rights reserved.
//


// Import the interfaces
#import "PunteggiSceneMamma.h"
#import "CustomIOS7AlertView.h"
#import "IntroScene.h"
#import "Singleton.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "AppDelegate.h"
#import "GAI.h"
// -----------------------------------------------------------------------
#pragma mark - IntroScene
// -----------------------------------------------------------------------

@implementation PunteggiSceneMamma
- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    [singleton setLeaderboardIdentifier:@"Woo_Woo_Leaderboard_Mamma"];

    NSString *userLocale = [[NSLocale currentLocale] localeIdentifier];
    NSString *userLanguage = [userLocale substringToIndex:2];
    
    NSInteger punteggioRecord = [singleton get_punteggio_mamma];
    NSInteger numeroPartite = [singleton get_partita_giocata_mamma];
    NSInteger puntiTotali = [singleton get_punti_totali_mamma];
    
    float mediaPunt;
    if(puntiTotali && numeroPartite)
        mediaPunt = (puntiTotali * 1.0f) / (numeroPartite * 1.0f);
    else
        mediaPunt = 0.0f;
    
    
    CCSprite *bgImage = [CCSprite spriteWithImageNamed:@"splashscreeniPhone5.png"];
    [bgImage setColor:[CCColor colorWithCcColor3b:ccc3(200, 200, 200)]];

    bgImage.position  = ccp(self.contentSize.width/2,self.contentSize.height/2);
    [self addChild:bgImage];

    CCLabelTTF *titleStartGame = [[CCLabelTTF alloc] init];
    titleStartGame = [CCLabelTTF labelWithString:@"Punteggi" fontName:@"Moon Flower Bold" fontSize:60];
    
    if([userLanguage isEqualToString:@"it"]){
        [titleStartGame setString:@"Punteggi"];
    }
    else
    {
        [titleStartGame setString:@"Scoreboard"];
    }
    titleStartGame.fontColor = [CCColor colorWithUIColor:[UIColor yellowColor]];
    titleStartGame.positionType = CCPositionTypeNormalized;
    titleStartGame.position = ccp(0.70f,0.90f);
    [self addChild:titleStartGame];
    
    CCLabelTTF *record = [[CCLabelTTF alloc] init];
    record = [CCLabelTTF labelWithString:@"Record:" fontName:@"Moon Flower" fontSize:30];
    record.fontColor = [CCColor colorWithUIColor:[UIColor whiteColor]];
    record.positionType = CCPositionTypeNormalized;
    record.position = ccp(0.70f,0.75f);
    [self addChild:record];

    CCLabelTTF *recordNumero = [[CCLabelTTF alloc] init];
    recordNumero = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%ld Gabbiani", (long)punteggioRecord] fontName:@"Moon Flower" fontSize:30];
    recordNumero.fontColor = [CCColor colorWithUIColor:[UIColor whiteColor]];
    recordNumero.positionType = CCPositionTypeNormalized;
    recordNumero.position = ccp(0.70f,0.65f);
    [self addChild:recordNumero];

    CCLabelTTF *punteggio = [[CCLabelTTF alloc] init];
    punteggio = [CCLabelTTF labelWithString:@"Punteggio medio:" fontName:@"Moon Flower" fontSize:30];
    punteggio.fontColor = [CCColor colorWithUIColor:[UIColor whiteColor]];
    punteggio.positionType = CCPositionTypeNormalized;
    punteggio.position = ccp(0.70f,0.50f);
    [self addChild:punteggio];
    

    
    if([userLanguage isEqualToString:@"it"]){
        [punteggio setString:@"Punteggio Medio :"];
    }
    else
    {
            [punteggio setString:@"Average points :"];
    }
    

    CCLabelTTF *punteggioNumero = [[CCLabelTTF alloc] init];
    punteggioNumero = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%.2f Gabbiani", mediaPunt] fontName:@"Moon Flower" fontSize:30];
    punteggioNumero.fontColor = [CCColor colorWithUIColor:[UIColor whiteColor]];
    punteggioNumero.positionType = CCPositionTypeNormalized;
    punteggioNumero.position = ccp(0.70f,0.40f);
    [self addChild:punteggioNumero];
    
    
    CCLabelTTF *partiteNumero = [[CCLabelTTF alloc] init];
    partiteNumero = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Hai giocato %ld volte", (long)numeroPartite] fontName:@"Moon Flower" fontSize:30];
    
    if([userLanguage isEqualToString:@"it"]){
        [partiteNumero setString:[NSString stringWithFormat:@"Hai giocato %ld volte", (long)numeroPartite]];
    }
    else
    {
        [partiteNumero setString:[NSString stringWithFormat:@"You played %ld times", (long)numeroPartite]];
    }
    
    partiteNumero.fontColor = [CCColor colorWithUIColor:[UIColor whiteColor]];
    partiteNumero.positionType = CCPositionTypeNormalized;
    partiteNumero.position = ccp(0.70f,0.25f);
    [self addChild:partiteNumero];
    

    CCButton *backButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_chiudi.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_chiudi.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_chiudi.png"]];
    backButton.positionType = CCPositionTypeNormalized;
    backButton.position = ccp(0.05f, 0.10f);
    [backButton setTarget:self selector:@selector(go_back)];
    [self addChild:backButton];
    
    CCButton *punteggi = [CCButton buttonWithTitle:@"Punteggi" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_label.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_label.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_label.png"]];
    punteggi.label.fontColor = [CCColor blackColor];
    punteggi.label.fontSize = 28;
    punteggi.label.fontName = @"Moon Flower Bold";
    punteggi.positionType = CCPositionTypeNormalized;
    punteggi.position = ccp(0.70f, 0.10f);
    //[punteggi setScale:0.5];
    
    [punteggi setTarget:self selector:@selector(go_punteggi)];
    [self addChild:punteggi];

    CCButton *medaglie = [CCButton buttonWithTitle:@"Medaglie" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_label.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_label.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_label.png"]];
    medaglie.label.fontColor = [CCColor blackColor];
    medaglie.label.fontSize = 28;
    medaglie.label.fontName = @"Moon Flower Bold";
    medaglie.positionType = CCPositionTypeNormalized;
    medaglie.position = ccp(0.30f, 0.10f);
    //[punteggi setScale:0.5];
    
    [medaglie setTarget:self selector:@selector(go_medaglie)];
    [self addChild:medaglie];
/*
    CCButton *condividiBtn = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_share.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_share.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_share.png"]];
    condividiBtn.positionType = CCPositionTypeNormalized;
    condividiBtn.position = ccp(0.95f, 0.10f);
    [condividiBtn setTarget:self selector:@selector(share_punteggi)];
    [self addChild:condividiBtn];
  */  

    CCButton *cancellaBtn = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_cestino.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_cestino.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_cestino.png"]];
    cancellaBtn.positionType = CCPositionTypeNormalized;
    cancellaBtn.position = ccp(0.95f, 0.10f);
    [cancellaBtn setTarget:self selector:@selector(deletePunteggi)];
    [self addChild:cancellaBtn];
    
    if ([GKLocalPlayer localPlayer].authenticated) {
        if([[singleton getLeaderBoardIdentifier] length] > 0) {
            //NSString *appoggio = [singleton getLeaderBoardIdentifier];
            //NSLog(appoggio);
            [self reportScore];
        }
    }
    
    // Returns t1.
    id<GAITracker> defaultTracker = [[GAI sharedInstance] defaultTracker];
    
    // Hit sent to UA-XXXX-1.
    [defaultTracker send:[[[GAIDictionaryBuilder createAppView]
                           set:@"Punteggi Screen" forKey:kGAIScreenName] build]];
    
	return self;
}

-(void)deletePunteggi {
    [singleton cancella_punteggi_mamma];
    
    [self init];
}

-(void)go_medaglie {

    [self showLeaderboardAndAchievements:NO];
}

-(void)go_punteggi {
    [self showLeaderboardAndAchievements:YES];

}

-(void)go_back {
    [[CCDirector sharedDirector] replaceScene:[IntroScene scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionInvalid duration:0.1F]];
}

-(void)reportScore{
    GKScore *score = [[GKScore alloc] initWithLeaderboardIdentifier:[singleton getLeaderBoardIdentifier]];
    score.value = [singleton get_punteggio_mamma];
    
    [GKScore reportScores:@[score] withCompletionHandler:^(NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
}

-(void)share_punteggi {
    
}

// -----------------------------------------------------------------------
#pragma mark - Create & Destroy
// -----------------------------------------------------------------------

+ (PunteggiSceneMamma *)scene
{
	return [[self alloc] init];
}

// -----------------------------------------------------------------------
-(void)showLeaderboardAndAchievements:(BOOL)shouldShowLeaderboard{
    GKGameCenterViewController *gcViewController = [[GKGameCenterViewController alloc] init];
    
    gcViewController.gameCenterDelegate = self;
    
    if (shouldShowLeaderboard) {
        gcViewController.viewState = GKGameCenterViewControllerStateLeaderboards;
        gcViewController.leaderboardIdentifier = [singleton getLeaderBoardIdentifier];
    }
    else{
        gcViewController.viewState = GKGameCenterViewControllerStateAchievements;
    }
    
    [[CCDirector sharedDirector] presentViewController:gcViewController animated:YES completion:nil];
}

-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
