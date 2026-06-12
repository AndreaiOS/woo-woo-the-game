//
//  GameOverSceneMamma.m
//  Woo Woo The Game
//
//  Created by Andrea Murru on 12/08/14.
//  Copyright (c) 2014 Andrea Murru. All rights reserved.
//

#import "GameOverSceneMamma.h"
#import "PunteggiSceneMamma.h"
#import "CustomIOS7AlertView.h"
#import "IntroScene.h"
#import "Singleton.h"
#import "MyScene2.h"
#import "AppDelegate.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "GAI.h"

@implementation GameOverSceneMamma
- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);

    CCSprite *bgImage = [CCSprite spriteWithImageNamed:@"splashscreeniPhone5.png"];
    [bgImage setColor:[CCColor colorWithCcColor3b:ccc3(200, 200, 200)]];
    
    bgImage.position  = ccp(self.contentSize.width/2,self.contentSize.height/2);
    [self addChild:bgImage];

    
    punteggio = [singleton get_punteggio_temp_mamma];
    
    CCLabelTTF *lblPunteggio = [[CCLabelTTF alloc] init];
    lblPunteggio = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Hai colpito\r\n%ld gabbiani ", (long)punteggio] fontName:@"Moon Flower" fontSize:50];
    lblPunteggio.fontColor = [CCColor colorWithUIColor:[UIColor whiteColor]];
    lblPunteggio.positionType = CCPositionTypeNormalized;
    lblPunteggio.position = ccp(0.70f,0.55f);
    [self addChild:lblPunteggio];
    
    backButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_chiudi.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_chiudi.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_chiudi.png"]];
    backButton.positionType = CCPositionTypeNormalized;
    backButton.position = ccp(0.05f, 0.10f);
    [backButton setTarget:self selector:@selector(go_back)];
    [self addChild:backButton];
    
    punteggi = [CCButton buttonWithTitle:@"Punteggi" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_label.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_label.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_label.png"]];
    punteggi.label.fontColor = [CCColor blackColor];
    punteggi.label.fontSize = 28;
    punteggi.label.fontName = @"Moon Flower Bold";
    punteggi.positionType = CCPositionTypeNormalized;
    punteggi.position = ccp(0.70f, 0.10f);
    //[punteggi setScale:0.5];
    
    [punteggi setTarget:self selector:@selector(go_punteggi)];
    [self addChild:punteggi];
    
    medaglie = [CCButton buttonWithTitle:@"Medaglie" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_label.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_label.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_label.png"]];
    medaglie.label.fontColor = [CCColor blackColor];
    medaglie.label.fontSize = 28;
    medaglie.label.fontName = @"Moon Flower Bold";
    medaglie.positionType = CCPositionTypeNormalized;
    medaglie.position = ccp(0.30f, 0.10f);
    //[punteggi setScale:0.5];
    
    [medaglie setTarget:self selector:@selector(go_medaglie)];
    [self addChild:medaglie];
    
    rigiocaBtn = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_rotate_right.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_rotate_right.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_rotate_right.png"]];
    rigiocaBtn.positionType = CCPositionTypeNormalized;
    rigiocaBtn.position = ccp(0.95f, 0.10f);
    [rigiocaBtn setTarget:self selector:@selector(rigioca)];
    [self addChild:rigiocaBtn];

    
    [singleton aggiungi_partita_giocata_mamma];
    [singleton aggiungi_punti_totali_mamma:punteggio];
    
    if([singleton get_punteggio_mamma] < punteggio) {
        //Nuovo record
        [singleton set_punteggio_mamma:punteggio];
        
        CCLabelTTF *lblPunteggio2 = [[CCLabelTTF alloc] init];
        lblPunteggio2 = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Nuovo record!! "] fontName:@"Moon Flower" fontSize:50];
        lblPunteggio2.fontColor = [CCColor colorWithUIColor:[UIColor whiteColor]];
        lblPunteggio2.positionType = CCPositionTypeNormalized;
        lblPunteggio2.position = ccp(0.70f,0.30f);
        [self addChild:lblPunteggio2];
    }
    /*
    interstitial_ = [[GADInterstitial alloc] init];
    interstitial_.adUnitID = @"ca-app-pub-9494589041643098/1566991963";
    interstitial_.delegate = self;

    GADRequest *request = [[GADRequest alloc] init];

    [interstitial_ loadRequest:request];
*/
    
    if ([GKLocalPlayer localPlayer].authenticated) {
        if([[singleton getLeaderBoardIdentifier] length] > 0) {
            NSString *appoggio = [singleton getLeaderBoardIdentifier];
            //NSLog(appoggio);
            [self reportScore];
            [self updateAchievements];
        }
    }

    // Returns t1.
    id<GAITracker> defaultTracker = [[GAI sharedInstance] defaultTracker];
    

    
    // Hit sent to UA-XXXX-1.
    [defaultTracker send:[[[GAIDictionaryBuilder createAppView]
                           set:@"Game Over Screen" forKey:kGAIScreenName] build]];
    
    interstitial_ = [[GADInterstitial alloc] init];
    interstitial_.adUnitID = @"ca-app-pub-9494589041643098/1566991963";
    interstitial_.delegate = self;
    
    GADRequest *request = [[GADRequest alloc] init];
    
    [interstitial_ loadRequest:request];
    
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [spinner setFrame:CGRectMake(self.contentSize.width / 2.0 - 30.0, self.contentSize.height / 2.0 - 30.0, 80, 80)];
    spinner.color = [UIColor blackColor];
    //spinner.backgroundColor = [UIColor whiteColor];
    spinner.hidesWhenStopped = YES;
    [spinner startAnimating];
    //[self scheduleOnce:@selector(activityIndicatorStop) delay:5.0f];
    [[[CCDirector sharedDirector] view] addSubview:spinner];
    
    rigiocaBtn.userInteractionEnabled = FALSE;
    backButton.userInteractionEnabled = FALSE;
    punteggi.userInteractionEnabled = FALSE;
    medaglie.userInteractionEnabled = FALSE;
    
    timer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(timeUpdate) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    // done
    time = 0;
    
	return self;
}

-(void)timeUpdate {
    time = time + 0.1;
    
    if(time > 15.0) {
        interstitial_.delegate = nil;

        [spinner stopAnimating];
        
        
        rigiocaBtn.userInteractionEnabled = TRUE;
        backButton.userInteractionEnabled = TRUE;
        punteggi.userInteractionEnabled = TRUE;
        medaglie.userInteractionEnabled = TRUE;
        
        [timer invalidate];

    }
    
}

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad
{
    [spinner stopAnimating];
    
    [interstitial_ presentFromRootViewController:[CCDirector sharedDirector]];
    
    rigiocaBtn.userInteractionEnabled = TRUE;
    backButton.userInteractionEnabled = TRUE;
    punteggi.userInteractionEnabled = TRUE;
    medaglie.userInteractionEnabled = TRUE;
    
    [timer invalidate];

}

- (void)interstitial:(GADInterstitial *)interstitial didFailToReceiveAdWithError:(GADRequestError *)error {
    [spinner stopAnimating];
    
    //[[CCDirector sharedDirector] replaceScene:[GameOverScene scene]
    //                           withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionInvalid duration:0.1F]];
    
    rigiocaBtn.userInteractionEnabled = TRUE;
    backButton.userInteractionEnabled = TRUE;
    punteggi.userInteractionEnabled = TRUE;
    medaglie.userInteractionEnabled = TRUE;
    
    [timer invalidate];

}

- (void)interstitialWillDismissScreen:(GADInterstitial *)interstitial {
    //[[CCDirector sharedDirector] replaceScene:[GameOverScene scene]
    //                           withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionInvalid duration:0.1F]];
}
// -----------------------------------------------------------------------
#pragma mark - Create & Destroy
// -----------------------------------------------------------------------

+ (GameOverSceneMamma *)scene
{
	return [[self alloc] init];
}

// -----------------------------------------------------------------------


-(void)go_back {
    [[CCDirector sharedDirector] replaceScene:[IntroScene scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionInvalid duration:0.1F]];
}

-(void)rigioca {
    [[CCDirector sharedDirector] replaceScene:[MyScene2 scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionInvalid duration:0.1F]];
}

-(void)go_punteggi {
    [[CCDirector sharedDirector] replaceScene:[PunteggiSceneMamma scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionInvalid duration:0.1F]];
}

-(void)reportScore{
    GKScore *score = [[GKScore alloc] initWithLeaderboardIdentifier:[singleton getLeaderBoardIdentifier]];
    score.value = punteggio;
    
    [GKScore reportScores:@[score] withCompletionHandler:^(NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
}

-(void)updateAchievements{
    NSInteger numeroPartite = [singleton get_partita_giocata_mamma];
    
    NSString *achievementIdentifier;

    GKAchievement *scoreAchievement = nil;
    GKAchievement *levelAchievement = nil;

    BOOL progressInLevelAchievement = NO;

    //NSMutableArray *listArchievement = [[NSMutableArray alloc] initWithCapacity:1];

    
    if ([self isPrimeNumber]){
        achievementIdentifier = @"badge_numeriprimi";
        //[listArchievement addObject:achievementIdentifier];
        scoreAchievement = [[GKAchievement alloc] initWithIdentifier:achievementIdentifier];
        scoreAchievement.percentComplete = 100;
    }
    
    if (punteggio == 0) {
        achievementIdentifier = @"badge_0uccisi";
        //[listArchievement addObject:achievementIdentifier];
        progressInLevelAchievement = YES;
        levelAchievement = [[GKAchievement alloc] initWithIdentifier:achievementIdentifier];
                levelAchievement.percentComplete = 100;
    }
    if (punteggio == 42){
        achievementIdentifier = @"badge_42";
        //[listArchievement addObject:achievementIdentifier];
        scoreAchievement = [[GKAchievement alloc] initWithIdentifier:achievementIdentifier];
        scoreAchievement.percentComplete = 100;
    }
    if (punteggio >= 50){
        achievementIdentifier = @"badge_50uccisi";
        //[listArchievement addObject:achievementIdentifier];
        scoreAchievement = [[GKAchievement alloc] initWithIdentifier:achievementIdentifier];
        scoreAchievement.percentComplete = 100;
    }
    if (punteggio >= 100){
        achievementIdentifier = @"badge_100uccisi";
        //[listArchievement addObject:achievementIdentifier];
        scoreAchievement = [[GKAchievement alloc] initWithIdentifier:achievementIdentifier];
        scoreAchievement.percentComplete = 100;
    }
    if (numeroPartite == 0){
        achievementIdentifier = @"badge_1partita";
        //[listArchievement addObject:achievementIdentifier];
        progressInLevelAchievement = YES;
        levelAchievement = [[GKAchievement alloc] initWithIdentifier:achievementIdentifier];
        levelAchievement.percentComplete = 100;
    }
    if (numeroPartite == 9){
        achievementIdentifier = @"badge_10partite";
        //[listArchievement addObject:achievementIdentifier];
        progressInLevelAchievement = YES;
        levelAchievement = [[GKAchievement alloc] initWithIdentifier:achievementIdentifier];
        levelAchievement.percentComplete = 100;
    }
    if (numeroPartite == 99){
        achievementIdentifier = @"badge_100partite";
        //[listArchievement addObject:achievementIdentifier];
        progressInLevelAchievement = YES;
        levelAchievement = [[GKAchievement alloc] initWithIdentifier:achievementIdentifier];
        levelAchievement.percentComplete = 100;
    }

    
    if(scoreAchievement) {
        NSArray *achievements = (progressInLevelAchievement) ? @[levelAchievement, scoreAchievement] : @[scoreAchievement];

        [GKAchievement reportAchievements:achievements withCompletionHandler:^(NSError *error) {
            if (error != nil) {
                NSLog(@"%@", [error localizedDescription]);
            }
        }];
    }
}

-(BOOL)isPrimeNumber {
    NSInteger number = punteggio;
    
    BOOL isPrime=YES;
    
    
    for (int i=2; i < number -1; i++)
        
    {
        
        if (number % i == 0)
            
        {
            
            isPrime = NO;
            
            break;
            
        }
        
    }
    return isPrime;
}

-(void)go_medaglie {
    
    [self showLeaderboardAndAchievements:NO];
}

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
