//
//  LXCKVO.m
//  OCDemo
//
//  Created by 刘晓晨 on 2024/3/6.
//
#import "LXCKVO.h"
#import <objc/runtime.h>
#import <objc/message.h>
//
//  NSObject+kvo_block.m
//  leetCode
//
//  Created by 刘晓晨 on 2021/7/13.
//

static NSString *kvo_class_prefix = @"KVOClass_";
const void *kvo_observers = &kvo_observers;

typedef void(^MsgSendSuperBlock)(struct objc_super * _Nonnull super_struct,SEL sel);
typedef void(^CallBackBlock)(AddObserverBlock callBackBlock);

@implementation NSObject (kvo_block)

- (void)lxc_addObserver:(NSObject *)observer forKey:(NSString *)key boolBlock:(AddObserverBoolBlock)block {
    [self lxc_addObserver:observer forKey:key block:^(id  _Nonnull oldValue, id  _Nonnull newValue) {
        block([oldValue boolValue],[newValue boolValue]);
    }];
}

- (void)lxc_addObserver:(NSObject *)observer forKey:(NSString *)key block:(AddObserverBlock)block {
    
    // 1.判断属性是否存在
    SEL setterSelector = NSSelectorFromString(setterFromGetter(key));
    Method setterMethod = class_getInstanceMethod([self class], setterSelector);
    if (!setterMethod) {
        // 报异常,方便查找问题
        NSString *reason = [NSString stringWithFormat:@"%@没有%@对应的setter", self, key];
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:reason
                                     userInfo:nil];
    }
    
    //原始类
    Class originalClass = object_getClass(self);
    // 拿到原始类名
    NSString *oldClassName = NSStringFromClass(originalClass);
    
    //这里的判断主要是为了判断当前被监听对象是否已经被监听过,如果有被监听,则class名称带kvo前缀,不用重新创建子类,使用当前类即可
    if (![oldClassName hasPrefix:kvo_class_prefix]) {
        Class kvoClass =  [self makeKvoClassWithOriginalClassName:oldClassName];
        // 3.修改isa指针,使得self->isa指向子类
        object_setClass(self, kvoClass);
    }
    
    //方法重写
    [self overridesMethodWithSEL:setterSelector method:setterMethod];
    
    // 5.保存block及用于筛选的参数key和observer(这两个参数主要是在remove时候筛选使用)
    LXCObservationInfo *info = [[LXCObservationInfo alloc] init];
    info.block = block;
    info.key = key;
    info.observer = observer;
    
    // 6.将监听者信息保存
    [self addObservationInfo:info];
}

-(void)addObservationInfo:(LXCObservationInfo *)info {
    //这里创建数组是因为同一个对象可能会被多个地方监听,这个时候需要去执行多个block
    NSMutableArray *observers = objc_getAssociatedObject(self, kvo_observers);
    if (!observers) {
        //创建保存监听对象的数组
        observers = [NSMutableArray array];
        objc_setAssociatedObject(self, kvo_observers, observers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [observers addObject:info];
}

-(void)overridesMethodWithSEL:(SEL)sel method:(Method)method {
    //判断是否属性关联到kvo_setter上,比如id类型,需要将sel与kvo_setIdValue关联上,而第二次监听则不需要再次关联,但是实际发现重复添加并无问题
    const char *types = method_getTypeEncoding(method);
    NSString *ocTypes = [NSString stringWithCString:types encoding:NSUTF8StringEncoding];
    IMP imp = class_getMethodImplementation(object_getClass(self), sel);
    ocTypes = [ocTypes substringToIndex:ocTypes.length - 2];
    if ([ocTypes hasSuffix:getTypeString(@encode(id))]) {
        if (imp != (IMP)kvo_setIdValue) {
            class_addMethod(object_getClass(self), sel, (IMP)kvo_setIdValue, types);
        }
    } else if ([ocTypes hasSuffix:getTypeString(@encode(int))]) {
        if (imp != (IMP)kvo_setIntValue) {
            class_addMethod(object_getClass(self), sel, (IMP)kvo_setIntValue, types);
        }
    } else if ([ocTypes hasSuffix:getTypeString(@encode(NSInteger))]) {
        if (imp != (IMP)kvo_setNSIntegerValue) {
            class_addMethod(object_getClass(self), sel, (IMP)kvo_setNSIntegerValue, types);
        }
    } else if ([ocTypes hasSuffix:getTypeString(@encode(BOOL))]) {
        if (imp != (IMP)kvo_setNSIntegerValue) {
            class_addMethod(object_getClass(self), sel, (IMP)kvo_setNSIntegerValue, types);
        }
    }
}

-(void)lxc_removeObserver:(NSObject *)observer forKey:(NSString *)key {
    NSMutableArray *observers = objc_getAssociatedObject(self, kvo_observers);
    for (LXCObservationInfo *observerInfo in observers) {
        /*
         这里判断如果监听对象一致,监听属性一致,及删除
         此处遇到了一个颠覆我认知的一个问题如果在info中我用weak来修饰observer,这个时候这里observerInfo.observer是获取不到的,因为调用这个方法一般都是在dealloc中,所以我认为所有指向自己的弱引用指针被置为nil是发生在dealloc之前,是不是很不可思议,但是实践证明确实如此,所以在info中我改为用assign修饰,因为此时外部传入的observer是有值的,所以assign修饰不会出问题
         */
        if (observerInfo.observer == observer && [observerInfo.key isEqualToString:key]) {
            [observers removeObject:observerInfo];
            break;
        }
    }
}

//创建子类
- (Class)makeKvoClassWithOriginalClassName:(NSString *)originalClazzName {
    NSString *kvoClazzName = [kvo_class_prefix stringByAppendingString:originalClazzName];
    Class clazz = NSClassFromString(kvoClazzName);
    
    if (clazz) {
        return clazz;
    }
    
    Class originalClazz = object_getClass(self);
    
    //让新的Class继承自原始类
    clazz = objc_allocateClassPair(originalClazz, kvoClazzName.UTF8String, 0);
    
    //仿苹果隐藏子类(及重写本类的class对象方法)
    Method clazzMethod = class_getInstanceMethod(originalClazz, @selector(class));
    const char *types = method_getTypeEncoding(clazzMethod);
    class_addMethod(clazz, @selector(class), (IMP)kvo_class, types);
    
    //注册子类
    objc_registerClassPair(clazz);
    
    return clazz;
}

//重写class方法
Class kvo_class(id self, SEL _cmd) {
    return class_getSuperclass(object_getClass(self));
}

-(void)activeBlockWithObserveName:(NSString *)getterName withBlock:(void (^)(AddObserverBlock block))block {
    NSMutableArray *observers = objc_getAssociatedObject(self, kvo_observers);
    for (LXCObservationInfo *observer in observers) {
        if ([observer.key isEqualToString:getterName]) {
            block(observer.block);
        }
    }
}

//统一管理setter方法
-(void) kvo_set:(SEL)sel withGetterBlock:(MsgSendSuperBlock)getterBlock withSetterBlock:(MsgSendSuperBlock)setterBlock callBackBlock:(CallBackBlock)callBackBlock {
    NSString *setterName = NSStringFromSelector(sel);
    NSString *getterName = getterFromSetter(setterName);
    
    struct objc_super * _Nonnull super_struct = [self getSuperStruct];
    
    if (getterName && getterBlock != nil) {
        getterBlock(super_struct,NSSelectorFromString(getterName));
    }
    
    // 调用父类的方法(此处还有一种方式是修改self isa 指向原始类,修改后在修改为 子类,这里使用的是系统实现super的方式,顺便可以了解下super和self的区别)
    if (setterBlock != nil) {
        setterBlock(super_struct,sel);
    }
    
    [self activeBlockWithObserveName:getterName withBlock:^(AddObserverBlock block) {
        if (callBackBlock != nil) {
            callBackBlock(block);
        }
    }];
}

void  kvo_setIdValue(id self, SEL _cmd, id newValue) {
    __block id oldValue;
    [self kvo_set:_cmd withGetterBlock:^(struct objc_super * _Nonnull super_struct, SEL sel) {
        oldValue = ((id (*)(struct objc_super *, SEL))(void *)objc_msgSendSuper)(super_struct, sel);
    } withSetterBlock:^(struct objc_super * _Nonnull super_struct, SEL sel) {
        objc_msgSendSuper(super_struct, sel,newValue);
    } callBackBlock:^(AddObserverBlock callBackBlock) {
        callBackBlock(oldValue,newValue);
    }];
}

void  kvo_setIntValue(id self, SEL _cmd, int newValue) {
    __block int oldValue;
    [self kvo_set:_cmd withGetterBlock:^(struct objc_super * _Nonnull super_struct, SEL sel) {
        oldValue = ((int (*)(struct objc_super *, SEL))(void *)objc_msgSendSuper)(super_struct, sel);
    } withSetterBlock:^(struct objc_super * _Nonnull super_struct, SEL sel) {
        objc_msgSendSuper(super_struct, sel,newValue);
    } callBackBlock:^(AddObserverBlock callBackBlock) {
        callBackBlock(@(oldValue),@(newValue));
    }];
}

void  kvo_setNSIntegerValue(id self, SEL _cmd, NSInteger newValue) {
    __block NSInteger oldValue;
    [self kvo_set:_cmd withGetterBlock:^(struct objc_super * _Nonnull super_struct, SEL sel) {
        oldValue = ((NSInteger (*)(struct objc_super *, SEL))(void *)objc_msgSendSuper)(super_struct, sel);
    } withSetterBlock:^(struct objc_super * _Nonnull super_struct, SEL sel) {
        objc_msgSendSuper(super_struct, sel,newValue);
    } callBackBlock:^(AddObserverBlock callBackBlock) {
        callBackBlock(@(oldValue),@(newValue));
    }];
}

void  kvo_setBOOLValue(id self, SEL _cmd, BOOL newValue) {
    __block BOOL oldValue;
    [self kvo_set:_cmd withGetterBlock:^(struct objc_super * _Nonnull super_struct, SEL sel) {
        oldValue = ((NSInteger (*)(struct objc_super *, SEL))(void *)objc_msgSendSuper)(super_struct, sel);
    } withSetterBlock:^(struct objc_super * _Nonnull super_struct, SEL sel) {
        objc_msgSendSuper(super_struct, sel,newValue);
    } callBackBlock:^(AddObserverBlock callBackBlock) {
        callBackBlock(@(oldValue),@(newValue));
    }];
}

// 获取super_struct
-(struct objc_super *)getSuperStruct {
    id class = object_getClass(self);
    Class super_class = class_getSuperclass(class);
    struct objc_super * _Nonnull super_struct = malloc(sizeof(struct objc_super));
    super_struct->receiver = self;
    super_struct->super_class = super_class;
    return super_struct;
}

//通过属性获取setter字符串
NSString* setterFromGetter(NSString *key) {
    if (key.length > 0) {
        NSString *resultString = [key stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[key substringToIndex:1] capitalizedString]];
        return [NSString stringWithFormat:@"set%@:",resultString];
    }
    return nil;
}

//通过setter 获取getter
NSString* getterFromSetter(NSString *key) {
    if (key.length > 0) {
        NSString *resultString = [key substringFromIndex:3];
        resultString = [resultString substringToIndex:resultString.length - 1];
        return [resultString lowercaseString];
    }
    return nil;
}

NSString* getTypeString(char * typeC) {
    return [NSString stringWithCString:typeC];
}


@end
