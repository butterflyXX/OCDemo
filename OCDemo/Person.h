//
//  Person.h
//  OCDemo
//
//  Created by 刘晓晨 on 2024/3/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject

@property(nonatomic, assign) int age;
@property(nonatomic, assign) NSInteger score;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, assign) BOOL passed;

@end

NS_ASSUME_NONNULL_END
