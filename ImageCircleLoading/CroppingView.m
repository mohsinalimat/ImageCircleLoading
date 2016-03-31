//
//  CroppingView.m
//  ImageCircleLoading
//
//  Created by Thabu on 3/30/16.
//  Copyright © 2016 vivid. All rights reserved.
//

#import "CroppingView.h"

@interface CroppingView ()
@property (nonatomic) CGFloat circleRadius;
@property (nonatomic) CGPoint circleCenter;

@property (nonatomic, weak) CAShapeLayer *maskLayer;
@property (nonatomic, weak) CAShapeLayer *circleLayer;

@property (nonatomic, weak) UIPinchGestureRecognizer *pinch;
@property (nonatomic, weak) UIPanGestureRecognizer   *pan;
@end

@implementation CroppingView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.hidesBackButton=YES;
    self.CropImage.image = _origionalImage;
    
    // create layer mask for the image
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    self.CropImage.layer.mask = maskLayer;
    self.maskLayer = maskLayer;
    
    // create shape layer for circle we'll draw on top of image (the boundary of the circle)
    
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    circleLayer.lineWidth = 3.0;
    circleLayer.fillColor = [[UIColor clearColor] CGColor];
    circleLayer.strokeColor = [[UIColor blackColor] CGColor];
    [self.CropImage.layer addSublayer:circleLayer];
    self.circleLayer = circleLayer;
    
    // create circle path
    [self updateCirclePathAtLocation:CGPointMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0) radius:self.view.bounds.size.width * 0.30];
    
    // create pan gesture
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    pan.delegate = self;
    [self.CropImage addGestureRecognizer:pan];
    self.CropImage.userInteractionEnabled = YES;
    self.pan = pan;
    
    // create pan gesture
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    pinch.delegate = self;
    [self.view addGestureRecognizer:pinch];
    self.pinch = pinch;
}

- (void)updateCirclePathAtLocation:(CGPoint)location radius:(CGFloat)radius
{
    self.circleCenter = location;
    self.circleRadius = radius;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path addArcWithCenter:self.circleCenter
                    radius:self.circleRadius
                startAngle:0.0
                  endAngle:M_PI * 2.0
                 clockwise:YES];
    
    self.maskLayer.path = [path CGPath];
    self.circleLayer.path = [path CGPath];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)ClickOnDone:(id)sender {
    CGFloat scale  = [[self.CropImage.window screen] scale];
    CGFloat radius = self.circleRadius * scale;
    CGPoint center = CGPointMake(self.circleCenter.x * scale, self.circleCenter.y * scale);
    
    CGRect frame = CGRectMake(center.x - radius,
                              center.y - radius,
                              radius * 2.0,
                              radius * 2.0);
    
    // temporarily remove the circleLayer
    
    CALayer *circleLayer = self.circleLayer;
    [self.circleLayer removeFromSuperlayer];
    
    // render the clipped image
    
    UIGraphicsBeginImageContextWithOptions(self.CropImage.frame.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if ([self.CropImage respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)])
    {
        // if iOS 7, just draw it
        [self.CropImage drawViewHierarchyInRect:self.CropImage.bounds afterScreenUpdates:YES];
    }
    else
    {
        // if pre iOS 7, manually clip it
        CGContextAddArc(context, self.circleCenter.x, self.circleCenter.y, self.circleRadius, 0, M_PI * 2.0, YES);
        CGContextClip(context);
        [self.CropImage.layer renderInContext:context];
    }
    
    // capture the image and close the context
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // add the circleLayer back
    
    [self.CropImage.layer addSublayer:circleLayer];
    
    // crop the image
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], frame);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    
    //send image to destination
    [_delegate imageCropedInCircle:croppedImage];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Gesture recognizers

- (void)handlePan:(UIPanGestureRecognizer *)gesture
{
    static CGPoint oldCenter;
    CGPoint tranlation = [gesture translationInView:gesture.view];
    
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        oldCenter = self.circleCenter;
    }
    
    CGPoint newCenter = CGPointMake(oldCenter.x + tranlation.x, oldCenter.y + tranlation.y);
    
    [self updateCirclePathAtLocation:newCenter radius:self.circleRadius];
}

- (void)handlePinch:(UIPinchGestureRecognizer *)gesture
{
    static CGFloat oldRadius;
    CGFloat scale = [gesture scale];
    
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        oldRadius = self.circleRadius;
    }
    
    CGFloat newRadius = oldRadius * scale;
    
    [self updateCirclePathAtLocation:self.circleCenter radius:newRadius];
}


#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ((gestureRecognizer == self.pan   && otherGestureRecognizer == self.pinch) ||
        (gestureRecognizer == self.pinch && otherGestureRecognizer == self.pan))
    {
        return YES;
    }
    
    return NO;
}

@end
