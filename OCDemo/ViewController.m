//
//  ViewController.m
//  OCDemo
//
//  Created by 刘晓晨 on 2024/3/4.
//

#import "ViewController.h"
#import "Person.h"
#import <objc/runtime.h>
#import <malloc/malloc.h>
#import "LXCKVO.h"
#import "KVOBlockTestViewController.h"
#import "AFNTestViewController.h"
#import "HomeItemModel.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, strong) UITableView *tableView;

@property(nonatomic, strong) NSArray<HomeItemModel *> *items;

@end

static NSString *cellId = @"cellId";

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"OCDemo";
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.backgroundColor=[UIColor whiteColor];
    tableView.dataSource = self;
    tableView.delegate = self;
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellId];
    tableView.frame = self.view.bounds;
    
    [self.view addSubview:tableView];
    
    __weak typeof(self) weakSelf = self;
    self.items = @[
        [HomeItemModel ModelWithTitle:@"自定义kvo_block" block:^(NSString *title) {
            KVOBlockTestViewController *vc = [KVOBlockTestViewController new];
            vc.title = title;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }],
        [HomeItemModel ModelWithTitle:@"ANF" block:^(NSString *title) {
            AFNTestViewController *vc = [AFNTestViewController new];
            vc.title = title;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }]
    ];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    cell.textLabel.text = self.items[indexPath.row].title;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.items[indexPath.row].block(self.items[indexPath.row].title);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



@end
