//
//  HomeItemModel.h
//  OCDemo
//
//  Created by 刘晓晨 on 2024/3/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HomeItemModel : NSObject

@property(nonatomic, strong) NSString *title;
@property(nonatomic, copy) void(^block)(NSString * title);

+(instancetype)ModelWithTitle:(NSString *)title block:(void(^)(NSString *)) block;

@end

NS_ASSUME_NONNULL_END
