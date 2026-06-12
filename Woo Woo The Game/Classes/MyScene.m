//
//  HelloWorldScene.m
//  Woo Woo The Game
//
//  Created by Andrea Murru on 04/08/14.
//  Copyright Andrea Murru 2014. All rights reserved.
//
// -----------------------------------------------------------------------

#import "MyScene.h"
#import "IntroScene.h"
#import "CCDirector.h"
#import "Singleton.h"
#import "GameOverScene.h"
#import "AppDelegate.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "GAI.h"

#define PTM_RATIO 32.0
#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#define IS_IPHONE ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPhone" ] )
#define IS_IPHONE_5 ( IS_IPHONE && IS_WIDESCREEN )

// -----------------------------------------------------------------------
#pragma mark - HelloWorldScene
// -----------------------------------------------------------------------

@implementation MyScene
{
    CCSprite *_sprite;
}

// -----------------------------------------------------------------------
#pragma mark - Create & Destroy
// -----------------------------------------------------------------------

+ (MyScene *)scene
{
    return [[self alloc] init];
}

// -----------------------------------------------------------------------

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    
    // Enable touch handling on scene node

    
    _physicsWorld = [CCPhysicsNode node];
    _physicsWorld.gravity = ccp(0,0);
    //_physicsWorld.debugDraw = YES;
    _physicsWorld.collisionDelegate = self;
    


    CCSprite *bgImage = [CCSprite spriteWithImageNamed:@"bkg_cielo.png"];
    bgImage.position  = ccp(self.contentSize.width/2,self.contentSize.height/2);
    [self addChild:bgImage];
    
    CCSprite *nuvole = [CCSprite spriteWithImageNamed:@"bkg_nuvole.png"];
    nuvole.position  = ccp(self.contentSize.width * 2,self.contentSize.height/2);
    [self addChild:nuvole];
    
    
    CCActionMoveTo *actionMoveLeft = [CCActionMoveTo actionWithDuration:60.0f position:CGPointMake(- self.contentSize.width, self.contentSize.height / 2)];
    CCActionMoveTo *actionMoveRight = [CCActionMoveTo actionWithDuration:60.0f position:CGPointMake(self.contentSize.width * 2, self.contentSize.height / 2)];
    CCActionSequence * sequence = [CCActionSequence actionOne:actionMoveLeft two:actionMoveRight];
    [nuvole runAction:[CCActionRepeatForever actionWithAction:sequence]];

    CCSprite *palazzi = [CCSprite spriteWithImageNamed:@"bkg_palazzi.png"];
    palazzi.position  = ccp(self.contentSize.width/2,self.contentSize.height/2);
    [self addChild:palazzi];
    
    CCSprite *terrazzo = [CCSprite spriteWithImageNamed:@"bkg_terrazzo.png"];
    terrazzo.position  = ccp(self.contentSize.width/2,self.contentSize.height/2);
    [self addChild:terrazzo];
    
    CCButton *pause = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_pausa.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_pausa.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_pausa.png"]];
    pause.positionType = CCPositionTypeNormalized;
    //[sound setScale:0.5];
    pause.togglesSelectedState = true;
    pause.positionType = CCPositionTypeNormalized;
    pause.position = ccp(0.25f, 0.87f);
    [pause setTarget:self selector:@selector(checkPause)];
    [self addChild:pause];
    
    _player = [PlayerSprite PlayerSprite];
    _player.position = ccp(100.0, 105.0);

    CGFloat offsetXPlayer = _player.contentSize.width * _player.anchorPoint.x - (_player.contentSize.width / 2) ;
    CGFloat offsetYPlayer = _player.contentSize.height * _player.anchorPoint.y - (_player.contentSize.height / 2) - 5;
    
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
    
    _player.physicsBody = [CCPhysicsBody bodyWithPolygonFromPoints:figliaPoints count:7 cornerRadius:3.0];

    _player.physicsBody.collisionType  = @"playerCollision";

    [_physicsWorld addChild:_player];
    //[_player cammina];

    
    _mamma = [MammaSprite MammaSprite];
    _mamma.position  = ccp(self.contentSize.width/2,self.contentSize.height/4);
    
    CGFloat offsetX = _mamma.contentSize.width * _mamma.anchorPoint.x - (_mamma.contentSize.width / 2) - 20;
    CGFloat offsetY = _mamma.contentSize.height * _mamma.anchorPoint.y -( _mamma.contentSize.height / 2) - 5;
/*
    CGPoint puntoMamma1 = CGPointMake(4 - offsetX, 125 - offsetY);
    //CGPoint puntoMamma2 = CGPointMake(17 - offsetX, 128 - offsetY);
    //CGPoint puntoMamma3 = CGPointMake(26 - offsetX, 121 - offsetY);
    CGPoint puntoMamma4 = CGPointMake(26 - offsetX, 106 - offsetY);
    CGPoint puntoMamma5 = CGPointMake(22 - offsetX, 92 - offsetY);
    CGPoint puntoMamma6 = CGPointMake(30 - offsetX, 69 - offsetY);
    CGPoint puntoMamma7 = CGPointMake(49 - offsetX, 61 - offsetY);
//    CGPoint puntoMamma8 = CGPointMake(60 - offsetX, 63 - offsetY);
    CGPoint puntoMamma9 = CGPointMake(110 - offsetX, 53 - offsetY);
    //CGPoint puntoMamma10 = CGPointMake(118 - offsetX, 58 - offsetY);
    CGPoint puntoMamma11 = CGPointMake(110 - offsetX, 51 - offsetY);
    CGPoint puntoMamma12 = CGPointMake(111 - offsetX, 29 - offsetY);
    CGPoint puntoMamma13 = CGPointMake(91 - offsetX, 10 - offsetY);
    CGPoint puntoMamma14 = CGPointMake(89 - offsetX, 2 - offsetY);
    CGPoint puntoMamma15 = CGPointMake(2 - offsetX, 1 - offsetY);
    CGPoint puntoMamma16 = CGPointMake(0 - offsetX, 110 - offsetY);
*/
    CGPoint puntoMamma1 = CGPointMake(21 - offsetX, 127 - offsetY);
    CGPoint puntoMamma2 = CGPointMake(82 - offsetX, 37 - offsetY);
    CGPoint puntoMamma3 = CGPointMake(85 - offsetX, 4 - offsetY);
    CGPoint puntoMamma4 = CGPointMake(2 - offsetX, 2 - offsetY);
    CGPoint puntoMamma5 = CGPointMake(0 - offsetX, 113 - offsetY);
    CGPoint puntoMamma6 = CGPointMake(9 - offsetX, 127 - offsetY);
    
    CGPoint mammaPoints[] = {
        puntoMamma1, puntoMamma2, puntoMamma3, puntoMamma4, puntoMamma5,  puntoMamma6 }
    ;
    
    _mamma.physicsBody = [CCPhysicsBody bodyWithPolygonFromPoints:mammaPoints count:6 cornerRadius:3.0];

    _mamma.physicsBody.collisionType  = @"mammaCollision";
    [_physicsWorld addChild:_mamma];
    [_mamma vive];

    _lifeBar = [LifeBarSprite LifeBarSprite];
    _lifeBar.position  = ccp(self.contentSize.width/2 + 20,self.contentSize.height - 40);
    if(IS_IPHONE_5) {
        [_lifeBar setScale:1.4];
    } else {
        [_lifeBar setScale:1.1];
    }
    [self addChild:_lifeBar];
    
    //self.isAccelerometerEnabled = YES;
    //[self scheduleUpdate]
    mostri = 0;
    punteggio = 0;
    colpi_mostro = 0;
    
    if([singleton is_audio]) {
        [[OALSimpleAudio sharedInstance] playBg:@"main_theme_w_intro.mp3" loop:YES];
        [[OALSimpleAudio sharedInstance] setBgVolume:0.5];

    }
    [self setupHud];
    


    [self addChild:_physicsWorld];
    
    [self count_down];
    
    // Returns t1.
    id<GAITracker> defaultTracker = [[GAI sharedInstance] defaultTracker];
    
    // Hit sent to UA-XXXX-1.
    [defaultTracker send:[[[GAIDictionaryBuilder createAppView]
                           set:@"Home Screen" forKey:kGAIScreenName] build]];

	return self;
}


// -----------------------------------------------------------------------

- (void)dealloc
{
    // clean up code goes here
}

// -----------------------------------------------------------------------
#pragma mark - Enter & Exit
// -----------------------------------------------------------------------

- (void)onEnter
{
    // always call super onEnter first
    [super onEnter];
    
    // In pre-v3, touch enable and scheduleUpdate was called here
    // In v3, touch is enabled by setting userInteractionEnabled for the individual nodes
    // Per frame update is automatically enabled, if update is overridden

    //isMoving = true;
}

// -----------------------------------------------------------------------

- (void)onExit
{
    // always call super onExit last
    [super onExit];
}

// -----------------------------------------------------------------------
#pragma mark - Touch Handler
// -----------------------------------------------------------------------

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
    CGPoint touchLoc = [touch locationInNode:self];
    
    // Log touch location
    //CCLOG(@"Move sprite to @ %@",NSStringFromCGPoint(touchLoc));
    
    if(touchLoc.x > self.contentSize.width / 2) {
        [_player zacca_a_destra];
        
        if([singleton is_sound])
            [[OALSimpleAudio sharedInstance] playEffect:@"swing_00.mp3" loop:NO];
    }
    else {
        [_player zacca_a_sinistra];
        
        if([singleton is_sound])
            [[OALSimpleAudio sharedInstance] playEffect:@"swing_01.mp3" loop:NO];
    }
    

}

// -----------------------------------------------------------------------
#pragma mark - Button Callbacks
// -----------------------------------------------------------------------

- (void)onBackClicked:(id)sender
{
    // back to intro scene with transition
    [[CCDirector sharedDirector] replaceScene:[IntroScene scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionRight duration:1.0f]];
}

// -----------------------------------------------------------------------
#pragma mark - Accelerometer Delegate
// -----------------------------------------------------------------------
- (void)startMonitoringAcceleration
{
    if (_motionManager.accelerometerAvailable) {
        [_motionManager startAccelerometerUpdates];
        NSLog(@"accelerometer updates on...");
    }
}

- (void)stopMonitoringAcceleration
{
    if (_motionManager.accelerometerAvailable && _motionManager.accelerometerActive) {
        [_motionManager stopAccelerometerUpdates];
        NSLog(@"accelerometer updates off...");
    }
}

- (void)updatePlayerPositionFromMotionManager
{
    CMAccelerometerData* data = _motionManager.accelerometerData;
    if(!isMoving) {
        isMoving = true;
    }


    float deceleration = 0.1f, sensitivity = 20.0f, maxVelocity = 1400;

    if ([[UIDevice currentDevice] orientation] == UIInterfaceOrientationLandscapeLeft) {
        playerVelocity.x = playerVelocity.x * deceleration + data.acceleration.y * sensitivity;
        comeEraGirato = true;

    } else if([[UIDevice currentDevice] orientation] == UIInterfaceOrientationLandscapeRight) {
        playerVelocity.x = playerVelocity.x * deceleration - data.acceleration.y * sensitivity;
        comeEraGirato = false;

    } else if(comeEraGirato == true)
        playerVelocity.x = playerVelocity.x * deceleration + data.acceleration.y * sensitivity;
     else if(comeEraGirato == false)
         playerVelocity.x = playerVelocity.x * deceleration - data.acceleration.y * sensitivity;
    
    if (playerVelocity.x > maxVelocity)
    {
        playerVelocity.x = maxVelocity;
    }
    else if (playerVelocity.x < -maxVelocity)
    {
        playerVelocity.x = -maxVelocity;
    }
    
    
    if (playerVelocity.y > maxVelocity)
    {
        playerVelocity.y = maxVelocity;
    }
    else if (playerVelocity.y < -maxVelocity)
    {
        playerVelocity.y = -maxVelocity;
    }
}

- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    
    self.lastSpawnTimeInterval = self.lastSpawnTimeInterval + timeSinceLast;
    if (self.lastSpawnTimeInterval > 5.2) {
        self.lastSpawnTimeInterval = 3;
        
        //if(mostri==0)
            [self addMonster];
    }
}



- (void)update:(CCTime)delta {


    CGPoint pos = _player.position; pos.x += playerVelocity.x;
    pos.y += playerVelocity.y;
    
    CGSize screenSize = self.contentSize;
    
    //float imageWidthHalved = _player.texture.contentSize.width * 0.5f;
    float imageWidthHalved = _player.texture.contentSize.width / 5.0f;

    float imageHeightHalved = _player.texture.contentSize.height * 0.5f;
    
    float leftBorderLimit = imageWidthHalved;
    float rightBorderLimit = screenSize.width - imageWidthHalved;
    float topBorderLimit = imageHeightHalved;
    float bottomBorderLimit = screenSize.height - imageHeightHalved;
    
    if (pos.x < leftBorderLimit)
    {
        pos.x = leftBorderLimit;
        playerVelocity.x = 0;
    }
    else if (pos.x > rightBorderLimit)
    {
        pos.x = rightBorderLimit;
        playerVelocity.x = 0;
    }
    
    if (pos.y < topBorderLimit)
    {
        pos.y = topBorderLimit;
        playerVelocity.y = 0; }
    else if (pos.y > bottomBorderLimit)
    {
        pos.y = bottomBorderLimit;
        playerVelocity.y = 0; 
    }
    
    _player.position = pos;
    
    [self updatePlayerPositionFromMotionManager];
    [self updateWithTimeSinceLastUpdate:delta];

    //[self checkCollisions];
}

- (void)addMonster {
    NSMutableArray *movimenti = [[NSMutableArray alloc] init];

    if([singleton is_sound])
        [[OALSimpleAudio sharedInstance] playEffect:@"woowoo.mp3" loop:NO];

    mostri++;
    
    // Create sprite
    GabbianoSprite *monster = [GabbianoSprite GabbianoSprite];
    //monster.position  = ccp(100,self.contentSize.height/2);
    monster.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, monster.contentSize} cornerRadius:0];
    //monster.physicsBody.collisionGroup = @"monsterGroup";
    monster.physicsBody.collisionType  = @"gabbianoCollision";
    [monster vola];
    // Determine where to spawn the monster along the Y axis
    
    BOOL isDestra = (arc4random() % 2) - 1;
    
    if(isDestra) {
        monster.position = CGPointMake(self.contentSize.width + 30, self.contentSize.height);
        NSLog(@"Parte da Destra");
        CCActionFlipX *revese = [CCActionFlipX actionWithFlipX:true];

        [movimenti addObject:revese];
        
    } else {
        monster.position = CGPointMake(0 - 30, self.contentSize.height);
        NSLog(@"Parte da Sinistra");

    }
    
    precX = monster.position.x;
    precY = monster.position.y;
    precDeltaX = 0;
    /*
    monster.physicsBody.collisionType=@"player";
    monster.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:monster.contentSize.width/2 andCenter:ccp(monster.contentSize.width/2, _player.contentSize.height/2)];
    monster.physicsBody.type = CCPhysicsBodyTypeDynamic;
*/
    [_physicsWorld addChild:monster];
    
    // Determine speed of the monster
    float increment_inverse_velocity = 180.0f;
    float durata = increment_inverse_velocity / ((mostri) + (increment_inverse_velocity / 2.0f));
    
    // Create the actions
    
    monster.physicsBody.allowsRotation = NO;
    
    
    for (int i = 0; i < 10; i++) {
        int miX = 0 - 30;
        int maxX = self.contentSize.width + 30;
        int rangeX =  maxX - miX;
        int actualX = (arc4random() % rangeX) + miX;
        
        int miY = monster.contentSize.height;
        int maxY = self.contentSize.height - 10;
        int rangeY =  maxY - miY;
        int actualY = (arc4random() % rangeY) + miY;
        
        
        float deltaX = precX - actualX;
        float deltaY = precY - actualY;
        
        float distance = sqrtf(deltaX*deltaX + deltaY*deltaY);
        
        float dur = (float) ((distance / maxX) * durata);
        
        
        CCActionMoveTo *moveDiagonal = [CCActionMoveTo actionWithDuration:dur position:CGPointMake(actualX, actualY)];

        if(deltaX < 0.0 && precDeltaX > 0.0) {
        CCActionFlipX *revese = [CCActionFlipX actionWithFlipX:false];
            [movimenti addObject:revese];
            NSLog(@"Destra");
            
        } else if(deltaX > 0.0 && precDeltaX > 0.0){
        CCActionFlipX *revese = [CCActionFlipX actionWithFlipX:true];
            [movimenti addObject:revese];
            NSLog(@"Sinistra");
        } else if(deltaX < 0.0 && precDeltaX < 0.0) {
        CCActionFlipX *revese = [CCActionFlipX actionWithFlipX:false];
            [movimenti addObject:revese];
            NSLog(@"Destra");
            
        } else if(deltaX > 0.0 && precDeltaX < 0.0){
        CCActionFlipX *revese = [CCActionFlipX actionWithFlipX:true];
            [movimenti addObject:revese];
            NSLog(@"Sinistra");
        }  else {
            NSLog(@"Non beccato");
            
        }
        
        [movimenti addObject:moveDiagonal];

        
        precX = actualX;
        precY = actualY;
        precDeltaX = deltaX;

            
        
        
    }
    
    float deltaX = precX - monster.position.x;
    float deltaY = precY - monster.position.y;
    
    float distance = sqrtf(deltaX*deltaX + deltaY*deltaY);
    int maxX = self.contentSize.width - 10;

    float dur = (float) ((distance / maxX) * durata);
    
    
    CCActionMoveTo *moveDiagonal = [CCActionMoveTo actionWithDuration:dur position:CGPointMake(monster.position.x, monster.position.y)];
    
    if(deltaX < 0.0 && precDeltaX > 0.0) {
        CCActionFlipX *revese = [CCActionFlipX actionWithFlipX:false];
        [movimenti addObject:revese];
        NSLog(@"Destra");
        
    } else if(deltaX > 0.0 && precDeltaX > 0.0){
        CCActionFlipX *revese = [CCActionFlipX actionWithFlipX:true];
        [movimenti addObject:revese];
        NSLog(@"Sinistra");
    } else if(deltaX < 0.0 && precDeltaX < 0.0) {
        CCActionFlipX *revese = [CCActionFlipX actionWithFlipX:false];
        [movimenti addObject:revese];
        NSLog(@"Destra");
        
    } else if(deltaX > 0.0 && precDeltaX < 0.0){
        CCActionFlipX *revese = [CCActionFlipX actionWithFlipX:true];
        [movimenti addObject:revese];
        NSLog(@"Sinistra");
    } else {
        NSLog(@"Non beccato");

    }
    [movimenti addObject:moveDiagonal];
    
    if(!isDestra) {
        CCActionFlipX *revese = [CCActionFlipX actionWithFlipX:true];
        [movimenti addObject:revese];
    }
    CCActionSequence *sequence = [CCActionSequence actionWithArray:movimenti];
    
    
    [monster runAction: [CCActionRepeatForever actionWithAction:sequence]];

    NSLog(@"----------- Fine ----------");

}

-(void)setupHud {
    scoreLabel = [CCLabelTTF labelWithString:@"Hits 000" fontName:@"Moon Flower Bold" fontSize:30];
    //1
    //3
    scoreLabel.fontColor = [CCColor redColor];
    scoreLabel.position = CGPointMake(self.contentSize.width - scoreLabel.contentSize.width + 20, self.contentSize.height - 40.0);

    [self addChild:scoreLabel];
    
    
    timeLabel = [CCLabelTTF labelWithString:@"Time 0" fontName:@"Moon Flower Bold" fontSize:30];

    //3
        timeLabel.fontColor = [CCColor redColor];
    timeLabel.position = CGPointMake(25 + timeLabel.contentSize.width/2, self.contentSize.height - 40.0);
    
    [self addChild:timeLabel];
    
}

-(void)timeUpdate {
    time = time + 0.1;
    [timeLabel setString: [NSString stringWithFormat:@"Time %.1f", time]];
    
}

- (BOOL)ccPhysicsCollisionPreSolve:(CCPhysicsCollisionPair *)pair playerCollision:(CCNode *)player gabbianoCollision:(CCNode *)gabbiano {
    NSLog(@"Collisione player / gabbiano ------------");
    colpi_mostro++;
    if(colpi_mostro <= 9)
        [_player colpita];

    [self controlla_vita];
    return NO;
}

- (BOOL)ccPhysicsCollisionPreSolve:(CCPhysicsCollisionPair *)pair mammaCollision:(CCNode *)mamma gabbianoCollision:(CCNode *)gabbiano {
    //NSLog(@"Collisione mamma / gabbiano ------------");
    [_mamma soffre];
    colpi_mostro++;
    if(colpi_mostro <= 9)
        [self controlla_vita];

    return NO;
}

- (BOOL)ccPhysicsCollisionPreSolve:(CCPhysicsCollisionPair *)pair mammaCollision:(CCNode *)mamma playerCollision:(CCNode *)player {
    return NO;
}

- (BOOL)ccPhysicsCollisionPreSolve:(CCPhysicsCollisionPair *)pair colpiCollision:(CCNode *)player gabbianoCollision:(GabbianoSprite *)gabbiano {
    
    NSLog(@"Collisione colpo / gabbiano ------------");
    
    [self valuta_colpo:gabbiano];
    
    return NO;
}

- (BOOL)ccPhysicsCollisionPreSolve:(CCPhysicsCollisionPair *)pair colpiCollision:(CCNode *)player mammaCollision:(CCNode *)mamma {
    return NO;
}

- (BOOL)ccPhysicsCollisionPreSolve:(CCPhysicsCollisionPair *)pair colpiCollision:(CCNode *)player fuocoCollision:(GabbianoSprite *)fuoco {
   
    NSLog(@"Elimina Gabbiano ------------");
    [fuoco stopAllActions];
    
    [fuoco muore];
    //[fuoco removeFromParentAndCleanup:true];
    
    punteggio++;
    
    [self setPunteggio];
    
    if([singleton is_sound])
        [[OALSimpleAudio sharedInstance] playEffect:@"con_la_scopa.mp3" loop:NO];
    
    return NO;
}

- (BOOL)ccPhysicsCollisionPreSolve:(CCPhysicsCollisionPair *)pair playerCollision:(CCNode *)player fuocoCollision:(GabbianoSprite *)fuoco {
    NSLog(@"Collisione player / fuoco ------------");
    colpi_mostro++;
    
    if(colpi_mostro <= 9)
        [_player colpita];

    [self controlla_vita];
    return NO;
}

- (BOOL)ccPhysicsCollisionPreSolve:(CCPhysicsCollisionPair *)pair mammaCollision:(CCNode *)mamma fuocoCollision:(GabbianoSprite *)fuoco {
    //NSLog(@"Collisione mamma / fuoco ------------");
    return NO;
}

- (BOOL)ccPhysicsCollisionPreSolve:(CCPhysicsCollisionPair *)pair colpitaCollision:(CCNode *)player gabbianoCollision:(GabbianoSprite *)gabbiano {

    return NO;
}

- (BOOL)ccPhysicsCollisionPreSolve:(CCPhysicsCollisionPair *)pair colpitaCollision:(CCNode *)player fuocoCollision:(GabbianoSprite *)fuoco {
    
    return NO;
}

- (BOOL)ccPhysicsCollisionPreSolve:(CCPhysicsCollisionPair *)pair colpitaCollision:(CCNode *)player mammaCollision:(GabbianoSprite *)mamma {
    
    return NO;
}

- (BOOL)ccPhysicsCollisionPreSolve:(CCPhysicsCollisionPair *)pair esenteCollision:(CCNode *)player mammaCollision:(GabbianoSprite *)mamma {
    
    return NO;
}

- (BOOL)ccPhysicsCollisionPreSolve:(CCPhysicsCollisionPair *)pair esenteCollision:(CCNode *)player fuocoCollision:(GabbianoSprite *)gabbiano {
    
    return NO;
}

- (BOOL)ccPhysicsCollisionPreSolve:(CCPhysicsCollisionPair *)pair esenteCollision:(CCNode *)player gabbianoCollision:(GabbianoSprite *)mamma {
    
    return NO;
}

- (BOOL)ccPhysicsCollisionPreSolve:(CCPhysicsCollisionPair *)pair mammaColpitaCollision:(CCNode *)mamma playerCollision:(GabbianoSprite *)player {
    
    return NO;
}

- (BOOL)ccPhysicsCollisionPreSolve:(CCPhysicsCollisionPair *)pair mammaColpitaCollision:(CCNode *)mamma fuocoCollision:(GabbianoSprite *)gabbiano {
    
    return NO;
}

- (BOOL)ccPhysicsCollisionPreSolve:(CCPhysicsCollisionPair *)pair mammaColpitaCollision:(CCNode *)mamma gabbianoCollision:(GabbianoSprite *)gabbiano {
    
    return NO;
}

- (BOOL)ccPhysicsCollisionPreSolve:(CCPhysicsCollisionPair *)pair mammaColpitaCollision:(CCNode *)mamma colpitaCollision:(GabbianoSprite *)player {
    
    return NO;
}

- (BOOL)ccPhysicsCollisionPreSolve:(CCPhysicsCollisionPair *)pair mammaColpitaCollision:(CCNode *)mamma colpiCollision:(GabbianoSprite *)player {
    
    return NO;
}

- (BOOL)ccPhysicsCollisionPreSolve:(CCPhysicsCollisionPair *)pair mammaColpitaCollision:(CCNode *)mamma esenteCollision:(GabbianoSprite *)player {
    
    return NO;
}


////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)ccPhysicsCollisionPreSolve:(CCPhysicsCollisionPair *)pair gabbianoMortoCollision:(GabbianoSprite *)gabbiano colpitaCollision:(CCNode *)player {
    
    return NO;
}

- (BOOL)ccPhysicsCollisionPreSolve:(CCPhysicsCollisionPair *)pair gabbianoMortoCollision:(GabbianoSprite *)gabbiano colpiCollision:(CCNode *)player {
    
    return NO;
}

- (BOOL)ccPhysicsCollisionPreSolve:(CCPhysicsCollisionPair *)pair gabbianoMortoCollision:(GabbianoSprite *)gabbiano esenteCollision:(CCNode *)player {
    return NO;
}

- (BOOL)ccPhysicsCollisionPreSolve:(CCPhysicsCollisionPair *)pair gabbianoMortoCollision:(GabbianoSprite *)gabbiano gabbianoCollision:(CCNode *)gabbiano2 {
    
    return NO;
}

- (BOOL)ccPhysicsCollisionPreSolve:(CCPhysicsCollisionPair *)pair gabbianoMortoCollision:(GabbianoSprite *)gabbiano fuocoCollision:(CCNode *)player {
    return NO;
}

- (BOOL)ccPhysicsCollisionPreSolve:(CCPhysicsCollisionPair *)pair gabbianoMortoCollision:(GabbianoSprite *)gabbiano playerCollision:(CCNode *)player {
    return NO;
}

- (BOOL)ccPhysicsCollisionPreSolve:(CCPhysicsCollisionPair *)pair gabbianoMortoCollision:(GabbianoSprite *)gabbiano mammaCollision:(CCNode *)player {
    return NO;
}

- (BOOL)ccPhysicsCollisionPreSolve:(CCPhysicsCollisionPair *)pair gabbianoMortoCollision:(GabbianoSprite *)gabbiano mammaColpitaCollision:(CCNode *)player {
    return NO;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)valuta_colpo:(GabbianoSprite *)gabbiano {
    [gabbiano stopActionByTag:777];

    [gabbiano fuoco];
    if([singleton is_sound])
        [[OALSimpleAudio sharedInstance] playEffect:@"bird_00.mp3" loop:NO];
    
    _player.physicsBody.collisionType  = @"esenteCollision";
    
    
}

-(void)setPunteggio {
    if(punteggio < 10)
        [scoreLabel setString:[NSString stringWithFormat:@"Hits 00%ld", (long)punteggio]];
    else if(punteggio < 100)
        [scoreLabel setString:[NSString stringWithFormat:@"Hits 0%ld", (long)punteggio]];
    else
        [scoreLabel setString:[NSString stringWithFormat:@"Hits %ld", (long)punteggio]];
}

-(void)controlla_vita {
    if(colpi_mostro < 9) {
        
        [_lifeBar set_vita:colpi_mostro];
    }
    else if(colpi_mostro == 9){
        if([singleton is_vibro])
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        
        self.userInteractionEnabled = NO;
        [self stopMonitoringAcceleration];
        [_player stopAllActions];
        [_player muore];
        [self performSelector:@selector(game_over) withObject:nil afterDelay:0.90];

    }
}

-(void)game_over {
    [self stopAllActions];
    

    [singleton set_punteggio_temp:punteggio];
    [[CCDirector sharedDirector] replaceScene:[GameOverScene scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionInvalid duration:0.1F]];
    
    
    /*
    interstitial_ = [[GADInterstitial alloc] init];
    interstitial_.adUnitID = @"ca-app-pub-9494589041643098/1566991963";
    interstitial_.delegate = self;
    
    GADRequest *request = [[GADRequest alloc] init];
    
    [interstitial_ loadRequest:request];
    
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [spinner setFrame:CGRectMake(self.contentSize.width / 2.0 - 20.0, self.contentSize.height / 2.0 - 20.0, 80, 80)];
    spinner.color = [UIColor blackColor];
    //spinner.backgroundColor = [UIColor whiteColor];
    spinner.hidesWhenStopped = YES;
    [spinner startAnimating];
    //[self scheduleOnce:@selector(activityIndicatorStop) delay:5.0f];
    [[[CCDirector sharedDirector] view] addSubview:spinner];*/
    
    if([singleton is_audio])
        [[OALSimpleAudio sharedInstance] stopBg];
    if([singleton is_sound]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[OALSimpleAudio sharedInstance] playEffect:@"mai_capitato.mp3" loop:NO];
        });
    }
    
    //self.userInteractionEnabled = FALSE;


}

-(void)count_down {

    pausa = [CCSprite spriteWithImageNamed:@"box_pausa.png"];
    pausa.position  = ccp(self.contentSize.width/2,self.contentSize.height/2);
    [self addChild:pausa];
    
    countdownLabel = [CCLabelTTF labelWithString:@"3" fontName:@"Moon Flower Bold" fontSize:120];
    
    //3
    countdownLabel.fontColor = [CCColor blackColor];
    countdownLabel.position  = ccp(self.contentSize.width/2,self.contentSize.height/2);
    
    [self addChild:countdownLabel];
    countTime = 3;

    [self schedule:@selector(countDown:) interval:1.0f];// 0.5second intervals


    //[[CCDirector sharedDirector] pause]; //Pauses current scene

}

-(void)countDown:(CCTime)delta
{

        countTime -= 1;
        //[countdownLabel setString:[NSString stringWithFormat:@"%i", countTime]];
        [countdownLabel setString: [NSString stringWithFormat:@"%d", countTime]];

    
    if(countTime == 0) {
        self.userInteractionEnabled = YES;
        [[CCDirector sharedDirector] resume]; //Resume current scene
        [countdownLabel removeFromParentAndCleanup:true];
        [pausa removeFromParentAndCleanup:true];
        [self unschedule:@selector(countDown:)];

        timer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(timeUpdate) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        // done
        time = 0;
        
        _motionManager = [[CMMotionManager alloc] init];
        
        [self startMonitoringAcceleration];
        [self updatePlayerPositionFromMotionManager];
        [_player cammina];

        
    }
    
}



-(void)checkPause {
    [[CCDirector sharedDirector] pause];
    [self stopMonitoringAcceleration];
    [_player stopAllActions];
    self.userInteractionEnabled = false;
    
    pauseStart = [NSDate dateWithTimeIntervalSinceNow:0];
    
    previousFireDate = [timer fireDate];
    
    [timer setFireDate:[NSDate distantFuture]];
    
    riprendi = [CCButton buttonWithTitle:@"Resume" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_label.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_label.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_label.png"]];
    riprendi.label.fontColor = [CCColor blackColor];
    riprendi.label.fontSize = 28;
    riprendi.label.fontName = @"Moon Flower Bold";
    riprendi.togglesSelectedState = true;
    riprendi.positionType = CCPositionTypeNormalized;
    riprendi.position = ccp(0.50f, 0.50f);
    [riprendi setTarget:self selector:@selector(riprendiDaPause)];
    riprendi.userInteractionEnabled = true;
    [self addChild:riprendi];
    
    esci = [CCButton buttonWithTitle:@"Exit" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_label.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_label.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_label.png"]];
    esci.label.fontColor = [CCColor blackColor];
    esci.label.fontSize = 28;
    esci.label.fontName = @"Moon Flower Bold";
    esci.togglesSelectedState = true;
    esci.positionType = CCPositionTypeNormalized;
    esci.position = ccp(0.50f, 0.65f);
    [esci setTarget:self selector:@selector(esci)];
    esci.userInteractionEnabled = true;
    [self addChild:esci];
    
}


-(void)esci {
    [self stopAllActions];
    
    [singleton set_punteggio_temp_mamma:punteggio];
    [[CCDirector sharedDirector] replaceScene:[IntroScene scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionInvalid duration:0.1F]];
    
    [riprendi removeFromParentAndCleanup:true];
    [esci removeFromParentAndCleanup:true];
    
    
    if([singleton is_audio])
        [[OALSimpleAudio sharedInstance] stopBg];
}

-(void)riprendiDaPause {
    [[CCDirector sharedDirector] resume];
    [self startMonitoringAcceleration];
    [_player cammina];
    
    self.userInteractionEnabled = true;
    
    float pauseTime = -1*[pauseStart timeIntervalSinceNow];
    
    [timer setFireDate:[previousFireDate initWithTimeInterval:pauseTime sinceDate:previousFireDate]];
    
    [riprendi removeFromParentAndCleanup:true];

    
    
}
/*
- (void)interstitialDidReceiveAd:(GADInterstitial *)ad
{
    [spinner stopAnimating];

    [interstitial_ presentFromRootViewController:[CCDirector sharedDirector]];
    
    self.userInteractionEnabled = TRUE;
}

- (void)interstitial:(GADInterstitial *)interstitial didFailToReceiveAdWithError:(GADRequestError *)error {
    [spinner stopAnimating];

    //[[CCDirector sharedDirector] replaceScene:[GameOverScene scene]
    //                           withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionInvalid duration:0.1F]];
    
    self.userInteractionEnabled = TRUE;
}

- (void)interstitialWillDismissScreen:(GADInterstitial *)interstitial {
    //[[CCDirector sharedDirector] replaceScene:[GameOverScene scene]
    //                           withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionInvalid duration:0.1F]];
}*/
@end
