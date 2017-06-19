/*
 <codex>
 <abstract>
 Utility methods for linear transformations of projective geometry.
 </abstract>
 </codex>
 */

#ifndef _OPENGL_MATH_TRANSFORMS_H_
#define _OPENGL_MATH_TRANSFORMS_H_

#import <simd/simd.h>
#import <OpenGL/OpenGL.h>

#ifdef __cplusplus

namespace GLM
{
    simd::float4x4 modelview(const bool& transpose);
    simd::float4x4 projection(const bool& transpose);
    simd::float4x4 texture(const bool& transpose);
    
    void identity(const GLenum& mode);
    
    void load(const bool& transpose,
              const simd::float4x4& M);
    
    simd::float4x4 scale(const GLfloat& x,
                         const GLfloat& y,
                         const GLfloat& z);
    
    simd::float4x4 scale(const simd::float3& s);
    
    simd::float4x4 translate(const GLfloat& x,
                             const GLfloat& y,
                             const GLfloat& z);
    
    simd::float4x4 translate(const simd::float3& t);
    
    simd::float4x4 rotate(const GLfloat& angle,
                          const GLfloat& x,
                          const GLfloat& y,
                          const GLfloat& z);
    
    simd::float4x4 rotate(const GLfloat& angle,
                          const simd::float3& u);
    
    simd::float4x4 rotate(const simd::float4& r);
    
    simd::float4x4 frustum(const GLfloat& left,
                           const GLfloat& right,
                           const GLfloat& bottom,
                           const GLfloat& top,
                           const GLfloat& near,
                           const GLfloat& far);
    
    simd::float4x4 frustum(const GLfloat& fovy,
                           const GLfloat& width,
                           const GLfloat& heigth,
                           const GLfloat& near,
                           const GLfloat& far);
    
    simd::float4x4 frustum(const GLfloat& fovy,
                           const GLfloat& aspect,
                           const GLfloat& near,
                           const GLfloat& far);
    
    simd::float4x4 lookAt(const GLfloat * const pEye,
                          const GLfloat * const pCenter,
                          const GLfloat * const pUp);
    
    simd::float4x4 lookAt(const simd::float3& eye,
                          const simd::float3& center,
                          const simd::float3& up);
    
    simd::float4x4 perspective(const GLfloat& fovy,
                               const GLfloat& aspect,
                               const GLfloat& near,
                               const GLfloat& far);
    
    simd::float4x4 perspective(const GLfloat& fovy,
                               const GLfloat& width,
                               const GLfloat& height,
                               const GLfloat& near,
                               const GLfloat& far);
    
    simd::float4x4 projection(const GLfloat& fovy,
                              const GLfloat& aspect,
                              const GLfloat& near,
                              const GLfloat& far);
    
    simd::float4x4 projection(const GLfloat& fovy,
                              const GLfloat& width,
                              const GLfloat& height,
                              const GLfloat& near,
                              const GLfloat& far);
    
    simd::float4x4 ortho(const GLfloat& left,
                         const GLfloat& right,
                         const GLfloat& bottom,
                         const GLfloat& top,
                         const GLfloat& near,
                         const GLfloat& far);
    
    simd::float4x4 ortho(const GLfloat& left,
                         const GLfloat& right,
                         const GLfloat& bottom,
                         const GLfloat& top);
    
    simd::float4x4 ortho(const simd::float3& origin,
                         const simd::float3& size);
} // GLM

#endif

#endif
