//
//  AFNTestViewController.m
//  OCDemo
//
//  Created by 刘晓晨 on 2024/3/7.
//

#import "AFNTestViewController.h"
#import "UIImageView+AFNetworking.h"

@interface AFNTestViewController ()

@property(nonatomic, strong) UIImageView *imageView;

@end

@implementation AFNTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blueColor];
    self.imageView = [[UIImageView alloc]init];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = YES;
    _imageView.frame = self.view.bounds;
    [self.view addSubview:_imageView];
    [_imageView setImageWithURL:[NSURL URLWithString:@"http://pic1.win4000.com/wallpaper/0/548966697feff.jpg"]];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
