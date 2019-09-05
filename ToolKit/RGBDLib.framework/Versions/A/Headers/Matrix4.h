//
//  Matrix4.h
//  WrinkleMe-mac
//
//  Created by Diego Thomas on 2018/02/17.
//  Copyright © 2018 3DLab. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <UIKit/UIKit.h>
#import <GLKit/GLKMath.h>

// Wraper around GLKMath's GLKMatrix4, becouse we can't use it directly from Swift code

@interface Matrix4 : NSObject{
@public
    GLKMatrix4 glkMatrix;
}

+ (Matrix4 * _Nonnull)makePerspectiveViewAngle:(float)angleRad
                                   aspectRatio:(float)aspect
                                         nearZ:(float)nearZ
                                          farZ:(float)farZ;

- (_Nonnull instancetype)init;
- (_Nonnull instancetype)copy;


- (void)scale:(float)x y:(float)y z:(float)z;
- (void)rotateAroundX:(float)xAngleRad y:(float)yAngleRad z:(float)zAngleRad;
- (void)translate:(float)x y:(float)y z:(float)z;
- (void)multiplyLeft:(Matrix4 * _Nonnull)matrix;


- (void * _Nonnull)raw;
- (void)transpose;

+ (float)degreesToRad:(float)degrees;
+ (NSInteger)numberOfElements;

@end

