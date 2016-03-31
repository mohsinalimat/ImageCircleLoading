//
//  ViewController.m
//  ImageCircleLoading
//
//  Created by Thabu on 3/30/16.
//  Copyright © 2016 vivid. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)ClickOnChoosePhoto:(id)sender {
    UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}
#pragma mark - UIImagePickerDelegate Methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    [picker dismissViewControllerAnimated:NO completion:nil];
    [self performSegueWithIdentifier:@"cropping" sender:image];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    CroppingView *vc = (CroppingView *)segue.destinationViewController;
    [vc setOrigionalImage:(UIImage *) sender];
    [vc setDelegate:self];
}
#pragma mark - Crop Image Delegate
- (void) imageCropedInCircle:(UIImage *)image{
    [_ProfileAvator setImage:image];
}
@end
