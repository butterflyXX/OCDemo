//
//  KVOBlockTestViewController.m
//  OCDemo
//
//  Created by 刘晓晨 on 2024/3/7.
//

#import "KVOBlockTestViewController.h"
#import "Person.h"
#import "LXCKVO.h"

@interface KVOBlockTestViewController ()

@property(nonatomic, strong) Person *p;

@end

@implementation KVOBlockTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeContactAdd];
    button.center = self.view.center;
    [button addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    Person *p = [Person new];
    p.age = 2;
    p.name = @"lili";
    p.score = 80;
    self.p = p;

    [p lxc_addObserver:self forKey:@"name" block:^(id  _Nonnull oldValue, id  _Nonnull newValue) {
        NSLog(@"%@",newValue);
    }];

    [p lxc_addObserver:self forKey:@"age" block:^(id  _Nonnull oldValue, id  _Nonnull newValue) {
        NSLog(@"%@",newValue);
    }];

    [p lxc_addObserver:self forKey:@"score" block:^(id  _Nonnull oldValue, id  _Nonnull newValue) {
        NSLog(@"%@",newValue);
    }];

    [p lxc_addObserver:self forKey:@"passed" boolBlock:^(BOOL oldValue, BOOL newValue) {
        NSLog(@"%d",newValue);
    }];
}

-(void)buttonClicked {
    self.p.age = self.p.age + 1;
    self.p.score = self.p.score + 1;
    self.p.name = [NSString stringWithFormat:@"%@1",self.p.name];
    self.p.passed = !self.p.passed;
}

-(void)dealloc {
    [self.p lxc_removeObserver:self forKey:@"name"];
    [self.p lxc_removeObserver:self forKey:@"age"];
    [self.p lxc_removeObserver:self forKey:@"score"];
    [self.p lxc_removeObserver:self forKey:@"passed"];
}

@end
