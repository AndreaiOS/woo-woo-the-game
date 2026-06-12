//
//  IntroScene.m
//  Woo Woo The Game
//
//  Created by Andrea Murru on 04/08/14.
//  Copyright Andrea Murru 2014. All rights reserved.
//
// -----------------------------------------------------------------------

// Import the interfaces
#import "IntroScene.h"
#import "MyScene.h"
#import "CustomIOS7AlertView.h"
#import "PunteggiScene.h"
#import "PunteggiSceneMamma.h"
#import "Singleton.h"
#import "TutorialScene.h"
#import "SelfieScene.h"
#import "AppDelegate.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "GAI.h"
#import "MyScene2.h"

// -----------------------------------------------------------------------
#pragma mark - IntroScene
// -----------------------------------------------------------------------

@implementation IntroScene

// -----------------------------------------------------------------------
#pragma mark - Create & Destroy
// -----------------------------------------------------------------------

+ (IntroScene *)scene
{
	return [[self alloc] init];
}

// -----------------------------------------------------------------------

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    
    CCSprite *bgImage = [CCSprite spriteWithImageNamed:@"splashscreeniPhone5.png"];
    bgImage.position  = ccp(self.contentSize.width/2,self.contentSize.height/2);
    //[bgImage setScale:0.5];

    [[CCDirector sharedDirector] setDisplayStats:NO];


    
    [self addChild:bgImage];
    
    // Hello world
    /*
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"Hello World" fontName:@"Chalkduster" fontSize:36.0f];
    label.positionType = CCPositionTypeNormalized;
    label.color = [CCColor redColor];
    label.position = ccp(0.5f, 0.5f); // Middle of screen
    [self addChild:label];
    */
    // Helloworld scene button
    //CCButton *startGame = [CCButton buttonWithTitle:@"btn_label.png"];

    
    
    CCSprite *title = [CCSprite spriteWithImageNamed:@"woowoothegame_titolo.png"];
    title.positionType = CCPositionTypeNormalized;

    title.position = ccp(0.70f,0.85f);
    [title setScale:0.5f];

    [self addChild:title];
    
    CCButton *startGame2 = [CCButton buttonWithTitle:@"Start Mamma" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_label.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_label.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_label.png"]];
    startGame2.label.fontColor = [CCColor blackColor];
    startGame2.label.fontSize = 28;
    startGame2.label.fontName = @"Moon Flower Bold";
    startGame2.positionType = CCPositionTypeNormalized;
    startGame2.position = ccp(0.30f, 0.60f);
    //[startGame setScale:0.5];
    
    [startGame2 setTarget:self selector:@selector(start_game_2)];
    [self addChild:startGame2];
    
    CCButton *startGame = [CCButton buttonWithTitle:@"Start" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_label.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_label.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_label.png"]];
    startGame.label.fontColor = [CCColor blackColor];
    startGame.label.fontSize = 28;
    startGame.label.fontName = @"Moon Flower Bold";
    startGame.positionType = CCPositionTypeNormalized;
    startGame.position = ccp(0.70f, 0.60f);
    //[startGame setScale:0.5];

    [startGame setTarget:self selector:@selector(start_game)];
    [self addChild:startGame];
    
    
    CCButton *punteggi = [CCButton buttonWithTitle:@"Punteggi" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_label.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_label.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_label.png"]];
    
    NSString *userLocale = [[NSLocale currentLocale] localeIdentifier];
    NSString *userLanguage = [userLocale substringToIndex:2];
    
    if([userLanguage isEqualToString:@"it"]){
        [punteggi setTitle:@"Punteggi"];
    }
    else
    {
        [punteggi setTitle:@"Score records"];

    }
    punteggi.label.fontColor = [CCColor blackColor];
    punteggi.label.fontSize = 28;
    punteggi.label.fontName = @"Moon Flower Bold";
    punteggi.positionType = CCPositionTypeNormalized;
    punteggi.position = ccp(0.70f, 0.45f);
    //[punteggi setScale:0.5];
    
    [punteggi setTarget:self selector:@selector(go_punteggi)];
    [self addChild:punteggi];
    
    
    
    
    CCButton *punteggiMamma = [CCButton buttonWithTitle:@"Punteggi" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_label.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_label.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_label.png"]];
    
    //NSString *userLocale = [[NSLocale currentLocale] localeIdentifier];
    //NSString *userLanguage = [userLocale substringToIndex:2];
    
    if([userLanguage isEqualToString:@"it"]){
        [punteggiMamma setTitle:@"Punteggi Mamma"];
    }
    else
    {
        [punteggiMamma setTitle:@"Score records Mother"];
        
    }
    punteggiMamma.label.fontColor = [CCColor blackColor];
    punteggiMamma.label.fontSize = 28;
    punteggiMamma.label.fontName = @"Moon Flower Bold";
    punteggiMamma.positionType = CCPositionTypeNormalized;
    punteggiMamma.position = ccp(0.30f, 0.45f);
    //[punteggi setScale:0.5];
    
    [punteggiMamma setTarget:self selector:@selector(go_punteggi_mamma)];
    [self addChild:punteggiMamma];
    
    
    CCButton *selfie = [CCButton buttonWithTitle:@"Woowoo Selfie" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_label.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_label.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_label.png"]];
    selfie.label.fontColor = [CCColor blackColor];
    selfie.label.fontSize = 28;
    selfie.label.fontName = @"Moon Flower Bold";
    selfie.positionType = CCPositionTypeNormalized;
    selfie.position = ccp(0.70f, 0.30f);
    //[punteggi setScale:0.5];
    
    [selfie setTarget:self selector:@selector(go_selfie)];
    [self addChild:selfie];
    
    CCButton *store = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_store.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_store.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_store.png"]];
    store.positionType = CCPositionTypeNormalized;
    //[vibro setScale:0.5];
    store.togglesSelectedState = true;
    store.position = ccp(0.52f, 0.15f);
    [store setTarget:self selector:@selector(checkStore)];
    [self addChild:store];
    
    audio = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_audioON.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_audioOFF.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_audioOFF.png"]];
    audio.positionType = CCPositionTypeNormalized;
    //[audio setScale:0.5];
    audio.togglesSelectedState = true;
    audio.position = ccp(0.61f, 0.15f);
    [audio setTarget:self selector:@selector(checkAudio)];
    [self addChild:audio];

    sound = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_soundON.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_soundOFF.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_soundOFF.png"]];
    sound.positionType = CCPositionTypeNormalized;
    //[sound setScale:0.5];
    sound.togglesSelectedState = true;
    sound.position = ccp(0.70f, 0.15f);
    [sound setTarget:self selector:@selector(checkSound)];
    [self addChild:sound];
    
    vibro = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_vibroON.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_vibroOFF.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_vibroOFF.png"]];
    vibro.positionType = CCPositionTypeNormalized;
    //[vibro setScale:0.5];
    vibro.togglesSelectedState = true;
    vibro.position = ccp(0.79f, 0.15f);
    [vibro setTarget:self selector:@selector(checkVibro)];
    [self addChild:vibro];
    
    info = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_crediti.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_crediti.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_crediti.png"]];
    info.positionType = CCPositionTypeNormalized;
    //[info setScale:0.5];

    info.position = ccp(0.88f, 0.15f);
    [info setTarget:self selector:@selector(go_info)];
    [self addChild:info];

    if([singleton is_first_time] == 0) {
        [vibro setSelected:false];
        [audio setSelected:false];
        [sound setSelected:false];
        
        [singleton cambia_audio:1];
        [singleton cambia_sound:1];
        [singleton cambia_vibro:1];

        [singleton set_first_time];
    } else {
    
    //[singleton cambia_vibro:[[NSUserDefaults standardUserDefaults] integerForKey: @"vibro"]];
    //NSLog([NSString stringWithFormat:@"%ld", (long)[[NSUserDefaults standardUserDefaults] integerForKey: @"vibro"]]);
    if([[NSUserDefaults standardUserDefaults] integerForKey: @"vibro"]!=0) {
        [vibro setSelected:false];
    } else {
        [vibro setSelected:true];
    }
    
    [singleton cambia_audio:[[NSUserDefaults standardUserDefaults] integerForKey: @"audio"]];
    if([[NSUserDefaults standardUserDefaults] integerForKey: @"audio"]!=0) {
        [audio setSelected:false];
    } else {
        [audio setSelected:true];
    }
    
    [singleton cambia_sound:[[NSUserDefaults standardUserDefaults] integerForKey: @"sound"]];
    if([[NSUserDefaults standardUserDefaults] integerForKey: @"sound"]!=0) {
        [sound setSelected:false];
    } else {
        [sound setSelected:true];
    }
    }
    [self authenticateLocalPlayer];
    
    // Returns t1.
    id<GAITracker> defaultTracker = [[GAI sharedInstance] defaultTracker];
    
    // Hit sent to UA-XXXX-1.
    [defaultTracker send:[[[GAIDictionaryBuilder createAppView]
                           set:@"Intro Screen" forKey:kGAIScreenName] build]];
    
	return self;
}

-(void)checkStore {
    // Returns t1.
    id<GAITracker> defaultTracker = [[GAI sharedInstance] defaultTracker];
    
    // Hit sent to UA-XXXX-1.
    [defaultTracker send:[[[GAIDictionaryBuilder createAppView]
                           set:@"Store Screen" forKey:kGAIScreenName] build]];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://bit.ly/woowoostore"]];

}

-(void)checkAudio {
    if(audio.selected == false) {
        NSLog(@"selected");
        [singleton cambia_audio:1];
        [[OALSimpleAudio sharedInstance] playEffect:@"music_on.mp3" loop:NO];

    }
    else {
        NSLog(@" not selected");
        [singleton cambia_audio:0];
    }
}

-(void)checkSound {
    if(sound.selected == false) {
        NSLog(@"selected");
        [singleton cambia_sound:1];
        [[OALSimpleAudio sharedInstance] playEffect:@"woowoo.mp3" loop:NO];

    }
    else {
        NSLog(@" not selected");
        [singleton cambia_sound:0];
    }
}

-(void)checkVibro {
    if(vibro.selected == false) {
        NSLog(@"selected");
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        [singleton cambia_vibro:1];
    }
    else {
        NSLog(@" not selected");
        [singleton cambia_vibro:0];
    }
}

-(void)go_info {
    
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 300, 200)];
        
        textView.dataDetectorTypes=UIDataDetectorTypeLink;
        textView.editable = false;
        textView.clipsToBounds = YES;
        textView.layer.cornerRadius = 10.0f;
        textView.textAlignment = NSTextAlignmentCenter;
        [textView setFont:[UIFont systemFontOfSize:16.0]];
        [textView setBackgroundColor:[UIColor clearColor]];


    
    NSString *userLocale = [[NSLocale currentLocale] localeIdentifier];
    NSString *userLanguage = [userLocale substringToIndex:2];
    
    if([userLanguage isEqualToString:@"it"]){
        [textView setText:@"Grazie del download!\r\nSeguici su Facebook:\r\nfb.com/woowoothegame\r\n\r\nCreato e ideato da:\r\nGiusepe Broccia e Davide Melis\r\n(sviluppo)\r\nfb.com/giudasoft\r\nRiccardo Atzeni (Grafica)\r\nAndrea Murru (swooluppo iOS)\r\n\r\nRingraziamo Sensational Gianni per la musica e l'ispirazione\r\nfb.com/sensationalgianni"];    }
    else
    {
        [textView setText:@"Thank you for download!\r\nFollow us on Facebook:\r\nfb.com/woowoothegame\r\n\r\nCreated by:\r\nGiusepe Broccia and Davide Melis\r\n(Develop)\r\nfb.com/giudasoft\r\nRiccardo Atzeni (Graphics)\r\nAndrea Murru (Dewoolop iOS)\r\n\r\nThanks to Sensational Gianni music and ispiration\r\nfb.com/sensationalgianni"];
    }
        
        CustomIOS7AlertView *alertView = [[CustomIOS7AlertView alloc] init];
        
        /*CustomIOS7AlertView * alertView = [[CustomIOS7AlertView alloc] initWithTitle:@"Woo woo v.1.1" message:textView.text delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];*/
        
        [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"OK", nil]];
        [alertView setUseMotionEffects:TRUE];
        
        [alertView setContainerView:textView];
        
        [alertView addSubview:textView];
        [alertView show];
    
    
}

-(void)start_game {
    [[CCDirector sharedDirector] replaceScene:[TutorialScene scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:0.7f]];
    
}

-(void)start_game_2 {
    [[CCDirector sharedDirector] replaceScene:[MyScene2 scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:0.7f]];
    
}


-(void)go_punteggi {
    // start spinning scene with transition
    [[CCDirector sharedDirector] replaceScene:[PunteggiScene scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionInvalid duration:0.1F]];
    
}

-(void)go_punteggi_mamma {
    // start spinning scene with transition
    [[CCDirector sharedDirector] replaceScene:[PunteggiSceneMamma scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionInvalid duration:0.1F]];
    
}

-(void)go_selfie {
    // start spinning scene with transition
    [[CCDirector sharedDirector] replaceScene:[SelfieScene scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionInvalid duration:0.1F]];
}


// -----------------------------------------------------------------------
#pragma mark - Button Callbacks
// -----------------------------------------------------------------------

- (void)onSpinningClicked:(id)sender
{
    // start spinning scene with transition
    [[CCDirector sharedDirector] replaceScene:[MyScene scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:1.0f]];
}

// -----------------------------------------------------------------------

-(void)authenticateLocalPlayer{

    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
        if (viewController != nil) {
            [[CCDirector sharedDirector] presentViewController:viewController animated:NO completion:nil];
        }
        else{
            if ([GKLocalPlayer localPlayer].authenticated) {
                [singleton setGameCenterEnabled:YES];
                
                // Get the default leaderboard identifier.
                [[GKLocalPlayer localPlayer] loadDefaultLeaderboardIdentifierWithCompletionHandler:^(NSString *leaderboardIdentifier, NSError *error) {
                    
                    if (error != nil) {
                        NSLog(@"%@", [error localizedDescription]);
                    }
                    else{
                        [singleton setLeaderboardIdentifier:leaderboardIdentifier];
                    }
                }];
            }
            
            else{
                [singleton setGameCenterEnabled:NO];
            }
        }
    };
}

@end
