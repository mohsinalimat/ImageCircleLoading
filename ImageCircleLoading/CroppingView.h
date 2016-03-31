//
//  CroppingView.h
//  ImageCircleLoading
//
//  Created by Thabu on 3/30/16.
//  Copyright © 2016 vivid. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CropImageDelegate <NSObject>
- (void) imageCropedInCircle : (UIImage *) image;
@end
@interface CroppingView : UIViewController<UIGestureRecognizerDelegate>

@property (nonatomic, retain) id <CropImageDelegate> delegate;
@property (nonatomic, retain) UIImage *origionalImage;

@property (strong, nonatomic) IBOutlet UIImageView *CropImage;
- (IBAction)ClickOnDone:(id)sender;

@end
