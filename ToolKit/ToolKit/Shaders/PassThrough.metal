//
//  PassThrough.metal
//  WrinkleMe-mac
//
//  Created by Diego Thomas on 2018/02/14.
//  Copyright © 2018 3DLab. All rights reserved.
//

//
//  PassThrough.metal
//  WrinkleMe
//
//  Created by Diego Thomas on 2017/12/22.
//  Copyright © 2017 3DLab. All rights reserved.
//

/*
 See LICENSE.txt for this sample’s licensing information.
 
 Abstract:
 Pass-through shader (used for preview).
 */

#include <metal_stdlib>
using namespace metal;

// Vertex input/output structure for passing results from vertex shader to fragment shader
struct VertexIO
{
    float4 position [[position]];
    float2 textureCoord [[user(texturecoord)]];
};

// Vertex shader for a textured quad
vertex VertexIO vertexPassThrough(device packed_float4 *pPosition  [[ buffer(0) ]],
                                  device packed_float2 *pTexCoords [[ buffer(1) ]],
                                  uint                  vid        [[ vertex_id ]])
{
    VertexIO outVertex;
    
    outVertex.position = pPosition[vid];
    outVertex.textureCoord = pTexCoords[vid];
    
    return outVertex;
}

// Fragment shader for a textured quad
fragment float4 fragmentPassThrough(VertexIO         inputFragment [[ stage_in ]],
                                   texture2d<float> inputTexture  [[ texture(0) ]],
                                   sampler         samplr        [[ sampler(0) ]])
{
    return inputTexture.sample(samplr, inputFragment.textureCoord);
}



