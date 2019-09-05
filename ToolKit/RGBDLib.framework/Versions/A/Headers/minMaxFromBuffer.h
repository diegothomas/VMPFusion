//
//  minMaxFromBuffer.h
//  WrinkleMe-mac
//
//  Created by Diego Thomas on 2018/02/20.
//  Copyright © 2018 3DLab. All rights reserved.
//

#ifndef minMaxFromBuffer_h
#define minMaxFromBuffer_h

#import <CoreVideo/CoreVideo.h>
#import <Metal/Metal.h>

void minMaxFromPixelBuffer(CVPixelBufferRef pixelBuffer, float* minValue, float* maxValue, MTLPixelFormat pixelFormat);

#endif /* minMaxFromBuffer_h */

