
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
//#import <Block_private.h>

struct Block_literal_1 {
    void *isa; // initialized to &_NSConcreteStackBlock or &_NSConcreteGlobalBlock
    int flags;
    int reserved;
    void (*invoke)(void *, ...);
    struct Block_descriptor_1 {
        unsigned long int reserved;         // NULL
        unsigned long int size;         // sizeof(struct Block_literal_1)
        // optional helper functions
        void (*copy_helper)(void *dst, void *src);     // IFF (1<<25)
        void (*dispose_helper)(void *src);             // IFF (1<<25)
        // required ABI.2010.3.16
        const char *signature;                         // IFF (1<<30)
    } *descriptor;
    // imported variables
};

extern const char *_Block_signature(void *block);
extern const char *_Block_layout(void *block);
//enum {
//    BLOCK_HAS_COPY_DISPOSE =  (1 << 25),
//    BLOCK_HAS_CTOR =          (1 << 26), // helpers have C++ code
//    BLOCK_IS_GLOBAL =         (1 << 28),
//    BLOCK_HAS_STRET =         (1 << 29), // IFF BLOCK_HAS_SIGNATURE
//    BLOCK_HAS_SIGNATURE =     (1 << 30),
//};
//
//switch (flags & (3<<29)) {
//    case (0<<29):      10.6.ABI, no signature field available
//    case (1<<29):      10.6.ABI, no signature field available
//    case (2<<29): ABI.2010.3.16, regular calling convention, presence of signature field
//    case (3<<29): ABI.2010.3.16, stret calling convention, presence of signature field,
//}

void print_block(void *b) {

    struct Block_literal_1 *block = b;

    int flags = block->flags;
    switch (flags & (3<<29)) {
        case (0<<29): //     10.6.ABI, no signature field available
        case (1<<29): //     10.6.ABI, no signature field available
            NSLog(@"no signature");
            break;
        case (2<<29): //ABI.2010.3.16, regular calling convention, presence of signature field
        case (3<<29): //ABI.2010.3.16, stret calling convention, presence of signature field,
        {
            void *field = &block->descriptor->copy_helper;

            if (flags & (1<<25)) {
                field += 2;
            }

            NSLog(@"signature = %s", *(const char **)field);

            NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:*(const char **)field];
            NSLog(@"NSMethodSignature = %@", [signature debugDescription]);

            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
            [invocation setArgument:&b atIndex:0];
//            [invocation setArgument:&empty atIndex:1];

            NSLog(@"block encoding = %s", @encode(void (^)(int)));
            NSLog(@"selector encoding = %s", @encode(SEL));

            BOOL hasInt = ([signature numberOfArguments] == 2 && strcmp([signature getArgumentTypeAtIndex:1], @encode(int)) == 0);

            if (hasInt) {
                int n = 5;
                [invocation setArgument:&n atIndex:1];
            }

            [invocation invoke];

            break;
        }
    }

}

@protocol Blah
+ (void)block1;
+ (void)block2:(int)i;
@end

//@interface INKJavaScriptSelector : INKJavaScriptHandler <Blah>
//@end
//
//@interface INKJavaScriptBlock : INKJavaScriptHandler
//@end

@interface NSInvocation (hack)
- (void)invokeUsingIMP:(IMP)imp;
@end

@interface INKJavaScriptHandler : NSObject

@end

@implementation INKJavaScriptHandler

//- (instancetype)handlerWithTarget:(id)target action:(SEL)action {
//
//}
//
//- (instancetype)handlerWithBlock:(id)block {
//
//}
//@end
//
//@implementation INKJavaScriptSelector

+ (void)load {
    void (^block1)(void) = ^{
        NSLog(@"block1");
    };

    void (^block2)(id, int) = ^(id block, int x){
        NSLog(@"block2 %d", x);
    };

    void (^block3)(int) = ^(int y) {
        NSLog(@"block3 %d", y);
    };

    IMP imp1 = imp_implementationWithBlock(block1);
    IMP imp2 = imp_implementationWithBlock(block2);

    NSLog(@"block1 = %p, block2 = %p", block1, block2);
    NSLog(@"imp1 = %p, imp2 = %p", imp1, imp2);


    print_block((__bridge void *)block1);
    print_block((__bridge void *)block2);

    const char *types1 = "v@:";
    const char *types2 = "v@:i";

    BOOL m1 = class_addMethod(object_getClass([self class]), @selector(block1), imp1, types1);
    BOOL m2 = class_addMethod(object_getClass([self class]), @selector(block2:), imp2, types2);

    NSLog(@"[self class] = %p, SEL = %p, block = %p, block_invoke = %p", [self class], @selector(block1), block1, ((__bridge struct Block_literal_1 *)block1)->invoke);
    [[self class] block1];
    [[self class] block2:6];
    block3(7);
    [[self class] note:8];

    struct Block_literal_1 *literal = (__bridge struct Block_literal_1 *)block3;

    void *field = &literal->descriptor->copy_helper;

    if (literal->flags & (1<<25)) {
        field += 2;
    }

    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:*(const char **)field]; // not checked
    NSInvocation *invocation = [NSClassFromString(@"NSBlockInvocation") invocationWithMethodSignature:signature];
    [invocation setTarget:(__bridge id)literal];
    [invocation setArgument:&(int){12} atIndex:1];
    [invocation invoke];

    invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:(__bridge id)literal];
    [invocation setArgument:&(int){13} atIndex:1];
    [invocation invokeUsingIMP:(IMP)literal->invoke];

    invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:(__bridge id)literal];
    [invocation setSelector:@selector(invoke)];
    [invocation setArgument:&(int){14} atIndex:1];
    [invocation invoke];

    NSMethodSignature *blockInvokeSignature = [(NSObject *)block3 methodSignatureForSelector:@selector(invoke)];
    NSLog(@"block method signature = %@", [blockInvokeSignature debugDescription]);

    NSMethodSignature *blockPrivateSignature = [NSMethodSignature signatureWithObjCTypes:_Block_signature((__bridge void *)block3)];
    NSLog(@"block private signature = %@", [blockPrivateSignature debugDescription]);
    NSLog(@"block layout = %s", _Block_layout((__bridge void *)block3));
    NSLog(@"block encoding = %s", @encode(void (^)(void)));
}

+ (void)note:(int)z {
    NSLog(@"note: %d", z);
}

@end

int main() {
    NSLog(@"%@", [INKJavaScriptHandler class]);
    return 1;
}

