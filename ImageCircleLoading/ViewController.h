//
//  ViewController.h
//  ImageCircleLoading
//
//  Created by Thabu on 3/30/16.
//  Copyright © 2016 vivid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CroppingView.h"
@interface ViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,CropImageDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *ProfileAvator;
- (IBAction)ClickOnChoosePhoto:(id)sender;
- (void) imageCropedInCircle:(UIImage *)image;

@end

