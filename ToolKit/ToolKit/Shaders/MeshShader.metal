//
//  ModelShader.metal
//  WrinkleMe-mac
//
//  Created by Diego Thomas on 2018/03/06.
//  Copyright © 2018 3DLab. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut{
    float4 position [[position]];
    float4 color;
    float2 texCoord;
    float3 normal;
    float3 fragmentPosition;
    float pointsize[[point_size]];
};

struct Light{
    packed_float3 color;      // 0 - 2
    float ambientIntensity;          // 3
    packed_float3 direction;  // 4 - 6
    float diffuseIntensity;   // 7
    float shininess;          // 8
    float specularIntensity;  // 9
    float dump1;
    float dump2;
    
    /*
     _______________________
     |0 1 2 3|4 5 6 7|8 9    |
     -----------------------
     |       |       |       |
     | chunk0| chunk1| chunk2|
     */
};

struct Uniforms{
    float4x4 modelMatrix;
    float4x4 projectionMatrix;
    Light light;
    packed_float4 flag;
};

/*float dot(float3 a, float3 b) {
    return a.x*b.x + a.y*b.y + a.z*b.z;
}*/

vertex VertexOut basic_vertex( const device packed_float3* vertex_array [[ buffer(0) ]],
                              const device packed_float3* nmle_array [[ buffer(1) ]],
                              const device Uniforms&  uniforms    [[ buffer(2) ]],
                           unsigned int vid [[ vertex_id ]]) {
    float4x4 mv_Matrix = uniforms.modelMatrix;
    
    float4 Vertex = float4(vertex_array[vid], 1.0);
    Vertex.y = -Vertex.y;
    Vertex.z = -Vertex.z;
    
    float4 VertexIn = mv_Matrix * Vertex;
    VertexIn.z = VertexIn.z+0.2f;
    VertexOut VertexOut;
    VertexOut.position = VertexIn; //mv_Matrix * float4(vertex_array[vid], 1.0);
    float4 NmleIn = float4(nmle_array[vid], 0.0);
    VertexOut.normal = (mv_Matrix * NmleIn).xyz;
    VertexOut.color = float4((1.0+VertexOut.normal.x)/2.0, (1.0-VertexOut.normal.y)/2.0, (1.0-VertexOut.normal.z)/2.0, 1.0);
    //VertexOut.pointsize = 10.0;
    return VertexOut;
}

fragment float4 basic_fragment(VertexOut interpolated [[stage_in]],
                               const device Uniforms&  uniforms    [[ buffer(1) ]]) {
    // Ambient
    Light light = uniforms.light;
    float4 ambientColor = float4(light.color * light.ambientIntensity, 1);
    //Diffuse
    float diffuseFactor = max(0.0,dot(interpolated.normal, light.direction));
    float4 diffuseColor = float4(light.color * light.diffuseIntensity * diffuseFactor ,1.0);
    /*//Specular
    float3 eye = normalize(interpolated.fragmentPosition);
    float3 reflection = reflect(light.direction, interpolated.normal);
    float specularFactor = pow(max(0.0, dot(reflection, eye)), light.shininess);
    float4 specularColor = float4(light.color * light.specularIntensity * specularFactor ,1.0);*/
    
    float4 color = interpolated.color;
    return color * (ambientColor + diffuseColor);// + specularColor);
}
    

vertex VertexOut model_vertex(const device packed_float3* vertex_array [[ buffer(0) ]],
                              const device packed_float3* nmle_array [[ buffer(1) ]],
                              const device packed_float3* color_array [[ buffer(2) ]],
                              const device Uniforms&  uniforms    [[ buffer(3) ]],
                              unsigned int vid [[ vertex_id ]]) {
    
    float4x4 mv_Matrix = uniforms.modelMatrix;
    float4x4 proj_Matrix = uniforms.projectionMatrix;
    
    float4 Vertex = float4(vertex_array[vid], 1.0);
    Vertex.y = -Vertex.y;
    Vertex.z = -Vertex.z;
    
    float4 VertexIn = Vertex;
    float4 ColorIn = float4(color_array[vid], 0.0);
    float4 flag = uniforms.flag;
    
    VertexOut VertexOut;
    VertexOut.position = mv_Matrix * VertexIn;
    VertexOut.fragmentPosition = VertexOut.position.xyz;
    VertexOut.position.z = VertexOut.position.z == 0.0? 0.0: VertexOut.position.z + 0.0f;
    VertexOut.position = proj_Matrix * VertexOut.position;
    
    float4 NmleIn = float4(nmle_array[vid], 0.0);
    VertexOut.normal = (mv_Matrix * NmleIn).xyz;
    if (flag.x == 1.0f)
        VertexOut.color = float4((1.0+VertexOut.normal.x)/2.0, (1.0-VertexOut.normal.y)/2.0, (1.0-VertexOut.normal.z)/2.0, 1.0);
    else
        VertexOut.color = ColorIn;
    ///VertexOut.texCoord = float2(0.0,0.0);
    //VertexOut.normal = (mv_Matrix  * (NmleIn)).xyz;
    VertexOut.pointsize = 5.0;
    
    return VertexOut;
}

fragment float4 model_fragment(VertexOut interpolated [[stage_in]],
                               const device Uniforms&  uniforms    [[ buffer(1) ]],
                               texture2d<float>  tex2D     [[ texture(0) ]],
                               depth2d<float> shadow    [[ texture(1) ]],
                               sampler           sampler2D [[ sampler(0) ]]) {
    // Ambient
    //Light light = uniforms.light;
    //float4 ambientColor = float4(light.color * light.ambientIntensity, 1);
    //Diffuse
    //float diffuseFactor = max(0.0,dot(interpolated.normal, light.direction));
    //float4 diffuseColor = float4(light.color * light.diffuseIntensity * diffuseFactor ,1.0);
    //Specular
    /*float3 eye = normalize(interpolated.fragmentPosition);
    float3 reflection = reflect(light.direction, interpolated.normal);
    float specularFactor = pow(max(0.0, dot(reflection, eye)), light.shininess);
    float4 specularColor = float4(light.color * light.specularIntensity * specularFactor ,1.0);*/
    
    float4 color = interpolated.color; //tex2D.sample(sampler2D, interpolated.texCoord);
    return color;// * (ambientColor + diffuseColor);// + specularColor);

}




