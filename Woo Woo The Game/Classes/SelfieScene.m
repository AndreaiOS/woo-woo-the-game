//
//  SelfieScene.m
//  Woo Woo The Game
//
//  Created by Andrea Murru on 14/08/14.
//  Copyright (c) 2014 Andrea Murru. All rights reserved.
//

#import "SelfieScene.h"
#import "IntroScene.h"
#import "AppDelegate.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "GAI.h"
#define IS_WIDESCREEN_IOS7 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#define IS_WIDESCREEN_IOS8 ( fabs( ( double )[ [ UIScreen mainScreen ] nativeBounds ].size.height - ( double )1136 ) < DBL_EPSILON || fabs( ( double )[ [ UIScreen mainScreen ] nativeBounds ].size.height - ( double )1704 ) < DBL_EPSILON )
#define IS_WIDESCREEN      ( ( [ [ UIScreen mainScreen ] respondsToSelector: @selector( nativeBounds ) ] ) ? IS_WIDESCREEN_IOS8 : IS_WIDESCREEN_IOS7 )



@implementation UIImagePickerController (NoRotate)

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

@implementation SelfieScene
- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    CCSprite *bgImage = [CCSprite spriteWithImageNamed:@"bkg_cielo-hd.png"];
    [bgImage setColor:[CCColor colorWithCcColor3b:ccc3(200, 200, 200)]];
    
    bgImage.position  = ccp(self.contentSize.width/2,self.contentSize.height/2);
    [self addChild:bgImage];
    
    
    CCButton *backButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_chiudi.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_chiudi.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_chiudi.png"]];
    backButton.positionType = CCPositionTypeNormalized;
    backButton.position = ccp(0.90f, 0.90f);
    [backButton setTarget:self selector:@selector(go_back)];
    [self addChild:backButton];
    
    
    selfie1 = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_cornice05.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_cornice05.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_cornice05.png"]];
    selfie1.positionType = CCPositionTypeNormalized;
    selfie1.position = ccp(0.10f, 0.10f);
    [selfie1 setTarget:self selector:@selector(setImageSelfie1)];
    [selfie1 setScale:0.8f];

    [self addChild:selfie1];
    
    
    selfie2 = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_cornice04.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_cornice04.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_cornice04.png"]];
    selfie2.positionType = CCPositionTypeNormalized;
    selfie2.position = ccp(0.10f, 0.30f);
    [selfie2 setTarget:self selector:@selector(setImageSelfie2)];
    [selfie2 setScale:0.8f];
    [self addChild:selfie2];
    
    
    selfie3 = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_cornice03.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_cornice03.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_cornice03.png"]];
    selfie3.positionType = CCPositionTypeNormalized;
    selfie3.position = ccp(0.10f, 0.50f);
    [selfie3 setTarget:self selector:@selector(setImageSelfie3)];
    [selfie3 setScale:0.8f];
    [self addChild:selfie3];
    
    
    selfie4 = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_cornice02.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_cornice02.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_cornice02.png"]];
    selfie4.positionType = CCPositionTypeNormalized;
    selfie4.position = ccp(0.10f, 0.70f);
    [selfie4 setTarget:self selector:@selector(setImageSelfie4)];
    [selfie4 setScale:0.8f];
    [self addChild:selfie4];
    
    
    selfie5 = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_cornice01.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_cornice01.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_cornice01.png"]];
    selfie5.positionType = CCPositionTypeNormalized;
    selfie5.position = ccp(0.15f, 0.90f);
    [selfie5 setTarget:self selector:@selector(setImageSelfie5)];
    [selfie5 setScale:0.8f];
    [self addChild:selfie5];
    
    
    CCButton *foto = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_foto.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_foto.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_foto.png"]];
    foto.positionType = CCPositionTypeNormalized;
    foto.position = ccp(0.90f, 0.50f);
    [foto setTarget:self selector:@selector(pickPhoto)];
    [foto setScale:0.8f];

    [self addChild:foto];
    
    CCButton *mirror = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_rotate_right.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_rotate_right.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_rotate_right.png"]];
    mirror.positionType = CCPositionTypeNormalized;
    mirror.position = ccp(0.90f, 0.30f);
    [mirror setTarget:self selector:@selector(flipImage)];
    [self addChild:mirror];
    
    CCButton *condividiBtn = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_share.png"] highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_share.png"] disabledSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"btn_share.png"]];
    condividiBtn.positionType = CCPositionTypeNormalized;
    condividiBtn.position = ccp(0.90f, 0.10f);
    [condividiBtn setTarget:self selector:@selector(share)];
    [self addChild:condividiBtn];
    
    immagine = @"WooWooSelfie_canvas01.png";

    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:@"UIDeviceOrientationDidChangeNotification"
                                               object:nil];
    
    CGSize imageSize = CGSizeMake(320, 320);
    UIColor *fillColor = [UIColor blackColor];
    UIGraphicsBeginImageContextWithOptions(imageSize, YES, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [fillColor setFill];
    CGContextFillRect(context, CGRectMake(0, 0, imageSize.width, imageSize.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    imageFromPicker = [CCSprite spriteWithCGImage:image.CGImage key:@"ImageFromPicker"];
    imageFromPicker.position = CGPointMake(self.contentSize.width / 2, self.contentSize.height / 2);
    
    imageFromPicker.scale = 0.4f;
    
    [self addChild:imageFromPicker];
    
    overlayImage = [CCSprite spriteWithImageNamed:immagine];
    if( [ [ UIScreen mainScreen ] respondsToSelector: @selector( nativeBounds ) ] )
    {
        /* Detect using nativeBounds - iOS 8 and greater */
    }
    else
    {
        /* Detect using bounds - iOS 7 and lower */
    }
    
    if(IS_WIDESCREEN) {
        overlayImage.position = CGPointMake((self.contentSize.width / 2) + 36, (self.contentSize.height / 2) + 160);
    } else {
        overlayImage.position = CGPointMake((self.contentSize.width / 2) + 80, (self.contentSize.height / 2) + 160);
    }
    overlayImage.scale = 0.8f;
    [imageFromPicker addChild:overlayImage];
    
    // Returns t1.
    id<GAITracker> defaultTracker = [[GAI sharedInstance] defaultTracker];
    
    // Hit sent to UA-XXXX-1.
    [defaultTracker send:[[[GAIDictionaryBuilder createAppView]
                           set:@"Selfie Screen" forKey:kGAIScreenName] build]];
    
    return self;
}

-(void)share {
    if(imageToBeSaved) {
        NSString *text = @"Woo woo Selfie";
        NSURL *url = [NSURL URLWithString:@"http://www.woowoothegame.com/"];
    
        UIActivityViewController *controller =
        [[UIActivityViewController alloc]
         initWithActivityItems:@[text, url, imageToBeSaved]
         applicationActivities:nil];
    
        [[CCDirector sharedDirector] presentViewController:controller animated:YES completion:nil];
    }
}

-(void)go_back {
    [[CCDirector sharedDirector] replaceScene:[IntroScene scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionInvalid duration:0.1F]];
}

// -----------------------------------------------------------------------
#pragma mark - Create & Destroy
// -----------------------------------------------------------------------

+ (SelfieScene *)scene
{
	return [[self alloc] init];
}

// -----------------------------------------------------------------------

-(void) pickPhoto
{
    picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.modalPresentationStyle = UIModalPresentationFullScreen;

    // Prevent the image picker learning about orientation changes by preventing the device from reporting them.
    UIDevice *currentDevice = [UIDevice currentDevice];
    
    // The device keeps count of orientation requests.  If the count is more than one, it continues detecting them and sending notifications.  So, switch them off repeatedly until the count reaches zero and they are genuinely off.
    // If orientation notifications are on when the view is presented, it may slide on in landscape mode even if the app is entirely portrait.
    // If other parts of the app require orientation notifications, the number "end" messages sent should be counted.  An equal number of "begin" messages should be sent after the image picker ends.
    while ([currentDevice isGeneratingDeviceOrientationNotifications])
        [currentDevice endGeneratingDeviceOrientationNotifications];
    
    // Display the camera.
    //[self presentModalViewController:picker animated:YES];
    
    
    
    
    
    CGRect f = picker.view.bounds;
    if(IS_WIDESCREEN_IOS8) {
        f.size.height = picker.navigationBar.bounds.size.width;

    } else {
        f.size.width -= picker.navigationBar.bounds.size.width;
    }

    //Create camera overlay
    CGFloat barHeight = ((f.size.width - f.size.height) / 2) - 20;
    UIGraphicsBeginImageContext(f.size);
    [[UIColor colorWithWhite:0 alpha:1.0] set];
    //UIRectFillUsingBlendMode(CGRectMake(0, 40, f.size.width, barHeight - 40), kCGBlendModeNormal);
    //UIRectFillUsingBlendMode(CGRectMake(0, f.size.width - barHeight - 40, f.size.height, barHeight), kCGBlendModeNormal);
    if(IS_WIDESCREEN_IOS8) {
        UIRectFillUsingBlendMode(CGRectMake(0, 0, 320, 90), kCGBlendModeNormal);
        UIRectFillUsingBlendMode(CGRectMake(0, f.size.width - 160, 320, 90), kCGBlendModeNormal);
    } else {
        UIRectFillUsingBlendMode(CGRectMake(0, 40, f.size.width, barHeight - 40), kCGBlendModeNormal);
        UIRectFillUsingBlendMode(CGRectMake(0, f.size.width - barHeight - 40, f.size.height, barHeight), kCGBlendModeNormal);
    }
    UIImage *overlayImageG = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageView *overlayIV = [[UIImageView alloc] initWithFrame:f];
    overlayIV.image = overlayImageG;


    
    // creating overlayView
    if(IS_WIDESCREEN) {
        //overlayViewP = [[UIView alloc] initWithFrame:CGRectMake(0, 88, 320, 320)];
        overlayViewP = [[UIView alloc] initWithFrame:CGRectMake(0, 88, f.size.width, 320)];
    } else {
        overlayViewP = [[UIView alloc] initWithFrame:CGRectMake(0, 44, 320, 320)];
    }
    //overlayViewP = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
    // letting png transparency be
    UIImage *imageBackground = [UIImage imageNamed:immagine];
    
    
    UIGraphicsBeginImageContext( CGSizeMake(320, 320) );
    [imageBackground drawInRect:CGRectMake(0,0,320,320)];
    UIImage* newImageP = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    

    
    overlayViewP.backgroundColor = [UIColor colorWithPatternImage:newImageP];
    [overlayViewP.layer setOpaque:NO];
    overlayViewP.opaque = NO;

    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    //picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    //picker.wantsFullScreenLayout = NO;
    picker.cameraOverlayView = overlayIV;
    [picker setAllowsEditing:true];
    //picker.cameraOverlayView = overlayViewP;
    [picker.cameraOverlayView addSubview:overlayViewP];
    picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;

    [[CCDirector sharedDirector] presentViewController:picker animated:false completion:^{
     
    }];
    
    // The UIImagePickerController switches on notifications AGAIN when it is presented, so switch them off again.
    while ([currentDevice isGeneratingDeviceOrientationNotifications])
        [currentDevice endGeneratingDeviceOrientationNotifications];
}

- (UIImage*)didTakePicture:(UIImage *)picture
{
    UIImage * flippedImage = [UIImage imageWithCGImage:picture.CGImage scale:picture.scale orientation:UIImageOrientationUpMirrored];
    
    picture = flippedImage;
    return picture;
}
/*
- (void)didTakePicture:(UIImage *)picture
{
    UIImage * flippedImage = [UIImage imageWithCGImage:picture.CGImage scale:picture.scale orientation:UIImageOrientationDownMirrored];
    
    picture = flippedImage;
}
*/
-(void)imagePickerController:(UIImagePickerController *)pickerS
didFinishPickingMediaWithInfo:(NSDictionary *)info{

    [[CCDirector sharedDirector] dismissViewControllerAnimated:true completion:^{
        newImage = nil;
        newImage = [info objectForKey:UIImagePickerControllerEditedImage];

        
        //UIImage *newImageTemp = [self didTakePicture:newImage];
        /*
        if(picker.cameraDevice == UIImagePickerControllerCameraDeviceFront)
        {
            UIImage *theImage = [info objectForKey:UIImagePickerControllerEditedImage];
            if (picker.cameraDevice == UIImagePickerControllerCameraDeviceFront) {
                CGSize imageSize = theImage.size;
                UIGraphicsBeginImageContextWithOptions(imageSize, YES, 1.0);
                CGContextRef ctx = UIGraphicsGetCurrentContext();
                CGContextRotateCTM(ctx, M_PI/2);
                CGContextTranslateCTM(ctx, 0, -imageSize.width);
                CGContextScaleCTM(ctx, imageSize.height/imageSize.width, imageSize.width/imageSize.height);
                CGContextDrawImage(ctx, CGRectMake(0.0, 0.0, imageSize.width, imageSize.height), theImage.CGImage);
                UIImage *newImage2 = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                newImage = newImage2;
            }
        }

        
        if(picker.cameraDevice == UIImagePickerControllerCameraDeviceFront) {

            
            CGRect             bnds = CGRectZero;
            UIImage*           copy = nil;
            CGContextRef       ctxt = nil;
            CGRect             rect = CGRectZero;
            CGAffineTransform  tran = CGAffineTransformIdentity;

            bnds.size = newImage.size;
            rect.size = newImage.size;

            tran = CGAffineTransformMakeTranslation(rect.size.width, 0.0);
            tran = CGAffineTransformScale(tran, -1.0, 1.0);
            
            UIGraphicsBeginImageContext(bnds.size);
            ctxt = UIGraphicsGetCurrentContext();
            
            CGContextScaleCTM(ctxt, 1.0, -1.0);
            CGContextTranslateCTM(ctxt, 0.0, -rect.size.height);
            CGContextConcatCTM(ctxt, tran);
            CGContextDrawImage(ctxt, rect, newImage.CGImage);
            
            copy = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();

            
            newImage = copy;
        }
        */
        
        CCTexture *texture2D = [[CCTexture alloc] initWithCGImage:newImage.CGImage contentScale:0.4f]; // this is new

        [imageFromPicker setTexture:texture2D];
        
        imageToBeSaved = [self convertSpriteToImage:imageFromPicker];
        imageFromPicker.scale = 0.4f;

        imageFromPicker.position = CGPointMake(self.contentSize.width / 2, self.contentSize.height / 2);

    }];
}

-(void)flipImage {
    
    CGRect             bnds = CGRectZero;
    UIImage*           copy = nil;
    CGContextRef       ctxt = nil;
    CGRect             rect = CGRectZero;
    CGAffineTransform  tran = CGAffineTransformIdentity;
    
    bnds.size = newImage.size;
    rect.size = newImage.size;
    
    tran = CGAffineTransformMakeTranslation(rect.size.width, 0.0);
    tran = CGAffineTransformScale(tran, -1.0, 1.0);
    
    UIGraphicsBeginImageContext(bnds.size);
    ctxt = UIGraphicsGetCurrentContext();
    
    CGContextScaleCTM(ctxt, 1.0, -1.0);
    CGContextTranslateCTM(ctxt, 0.0, -rect.size.height);
    CGContextConcatCTM(ctxt, tran);
    CGContextDrawImage(ctxt, rect, newImage.CGImage);
    
    copy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    newImage = copy;

    CCTexture *texture2D = [[CCTexture alloc] initWithCGImage:newImage.CGImage contentScale:0.4f]; // this is new
    
    [imageFromPicker setTexture:texture2D];
    
    imageToBeSaved = [self convertSpriteToImage:imageFromPicker];
    imageFromPicker.scale = 0.4f;
    
    imageFromPicker.position = CGPointMake(self.contentSize.width / 2, self.contentSize.height / 2);
    
    [overlayImage setSpriteFrame:[CCSpriteFrame frameWithImageNamed:immagine]];
    imageToBeSaved = [self convertSpriteToImage:imageFromPicker];
    imageFromPicker.scale = 0.4f;
    imageFromPicker.position = CGPointMake(self.contentSize.width / 2, self.contentSize.height / 2);
}

-(UIImage *)convertSpriteToImage:(CCSprite *)sprite
{
    sprite.scale = 1.0f;
    sprite.position = ccp(sprite.contentSize.width / 2, sprite.contentSize.height / 2);
    
    CCRenderTexture *renderer = [CCRenderTexture renderTextureWithWidth:sprite.contentSize.width height:sprite.contentSize.height];
    [renderer begin];
    [sprite visit];
    [renderer end];
    
    return [renderer getUIImage];
}

-(void)setImageSelfie1 {
    immagine = @"WooWooSelfie_canvas05.png";
   
    selfie1.position = ccp(0.10f, 0.10f);
    selfie2.position = ccp(0.10f, 0.30f);
    selfie3.position = ccp(0.10f, 0.50f);
    selfie4.position = ccp(0.10f, 0.70f);
    selfie5.position = ccp(0.10f, 0.90f);

    selfie1.position = ccp(0.15f, 0.10f);
    [overlayImage setSpriteFrame:[CCSpriteFrame frameWithImageNamed:immagine]];
    imageToBeSaved = [self convertSpriteToImage:imageFromPicker];
    imageFromPicker.scale = 0.4f;
    imageFromPicker.position = CGPointMake(self.contentSize.width / 2, self.contentSize.height / 2);
}
-(void)setImageSelfie2 {
    immagine = @"WooWooSelfie_canvas04.png";
    
    selfie1.position = ccp(0.10f, 0.10f);
    selfie2.position = ccp(0.10f, 0.30f);
    selfie3.position = ccp(0.10f, 0.50f);
    selfie4.position = ccp(0.10f, 0.70f);
    selfie5.position = ccp(0.10f, 0.90f);
    
    selfie2.position = ccp(0.15f, 0.30f);
    [overlayImage setSpriteFrame:[CCSpriteFrame frameWithImageNamed:immagine]];
    imageToBeSaved = [self convertSpriteToImage:imageFromPicker];
    imageFromPicker.scale = 0.4f;
    imageFromPicker.position = CGPointMake(self.contentSize.width / 2, self.contentSize.height / 2);
}
-(void)setImageSelfie3 {
    immagine = @"WooWooSelfie_canvas03.png";
    
    selfie1.position = ccp(0.10f, 0.10f);
    selfie2.position = ccp(0.10f, 0.30f);
    selfie3.position = ccp(0.10f, 0.50f);
    selfie4.position = ccp(0.10f, 0.70f);
    selfie5.position = ccp(0.10f, 0.90f);
    
    selfie3.position = ccp(0.15f, 0.50f);
    [overlayImage setSpriteFrame:[CCSpriteFrame frameWithImageNamed:immagine]];
    imageToBeSaved = [self convertSpriteToImage:imageFromPicker];
    imageFromPicker.scale = 0.4f;
    imageFromPicker.position = CGPointMake(self.contentSize.width / 2, self.contentSize.height / 2);
}
-(void)setImageSelfie4 {
    immagine = @"WooWooSelfie_canvas02.png";
    
    selfie1.position = ccp(0.10f, 0.10f);
    selfie2.position = ccp(0.10f, 0.30f);
    selfie3.position = ccp(0.10f, 0.50f);
    selfie4.position = ccp(0.10f, 0.70f);
    selfie5.position = ccp(0.10f, 0.90f);
    
    selfie4.position = ccp(0.15f, 0.70f);
    [overlayImage setSpriteFrame:[CCSpriteFrame frameWithImageNamed:immagine]];
    imageToBeSaved = [self convertSpriteToImage:imageFromPicker];
    imageFromPicker.scale = 0.4f;
    imageFromPicker.position = CGPointMake(self.contentSize.width / 2, self.contentSize.height / 2);
}
-(void)setImageSelfie5 {
    immagine = @"WooWooSelfie_canvas01.png";
    
    selfie1.position = ccp(0.10f, 0.10f);
    selfie2.position = ccp(0.10f, 0.30f);
    selfie3.position = ccp(0.10f, 0.50f);
    selfie4.position = ccp(0.10f, 0.70f);
    selfie5.position = ccp(0.10f, 0.90f);
    
    selfie5.position = ccp(0.15f, 0.90f);
    [overlayImage setSpriteFrame:[CCSpriteFrame frameWithImageNamed:immagine]];
    imageToBeSaved = [self convertSpriteToImage:imageFromPicker];
    imageFromPicker.scale = 0.4f;
    imageFromPicker.position = CGPointMake(self.contentSize.width / 2, self.contentSize.height / 2);
}

- (void) orientationChanged:(NSNotification *)notification{
    /*
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    //do stuff
    
    if (orientation==UIDeviceOrientationPortrait) {
        //picker.cameraOverlayView = portraitImageView;
                //[overlayViewP setHidden:false];
        overlayViewP.transform = CGAffineTransformMakeRotation(0);

    }
    
    else if(orientation==UIDeviceOrientationLandscapeLeft)
    {
        
        //picker.cameraOverlayView = landscapeImageViewLeft;
        //[overlayViewP setHidden:true];
        overlayViewP.transform = CGAffineTransformMakeRotation(M_PI/2);

    }
    
    else if(orientation==UIDeviceOrientationLandscapeRight)
    {
        
        //picker.cameraOverlayView = landscapeImageViewRight;
        //[overlayViewP setHidden:true];
        overlayViewP.transform = CGAffineTransformMakeRotation(-M_PI/2);

    }
    */
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    return NO;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

@end
