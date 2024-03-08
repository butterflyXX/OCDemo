//
//  HomeItemModel.m
//  OCDemo
//
//  Created by 刘晓晨 on 2024/3/8.
//

#import "HomeItemModel.h"

@implementation HomeItemModel

+(instancetype)ModelWithTitle:(NSString *)title block:(void(^)(NSString *title)) block {
    HomeItemModel *model = [[super alloc] init];
    model.title = title;
    model.block = block;
    return model;
}

@end
