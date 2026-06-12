//
//  SelfieScene.h
//  Woo Woo The Game
//
//  Created by Andrea Murru on 14/08/14.
//  Copyright (c) 2014 Andrea Murru. All rights reserved.
//

#import "cocos2d.h"
#import "cocos2d-ui.h"

@interface SelfieScene : CCScene <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    UIWindow *window;
    UIImage *newImage;
    
    NSString *immagine;
    
    CCButton *selfie1;
    CCButton *selfie2;
    CCButton *selfie3;
    CCButton *selfie4;
    CCButton *selfie5;

    UIImagePickerController * picker;
    
    UIView* overlayViewP;
    UIView* overlayViewL;
    
    UIImage *imageToBeSaved;
    CCSprite *imageFromPicker;
    
    CCSprite *overlayImage;
}
// -----------------------------------------------------------------------

+ (SelfieScene *)scene;
- (id)init;

// -----------------------------------------------------------------------
@end
