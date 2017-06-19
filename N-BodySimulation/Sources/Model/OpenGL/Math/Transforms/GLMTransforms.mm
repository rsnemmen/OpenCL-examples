/*
 <codex>
 <import>GLMTransforms.h</import>
 </codex>
 */

#pragma mark -
#pragma mark Private - Headers

#import <cmath>
#import <iostream>

#import <OpenGL/gl.h>

#import "GLMConstants.h"
#import "GLMTransforms.h"

#pragma mark -
#pragma mark Private - Constants

static GLfloat kIdentity[16] =
{
    1.0f, 0.0f, 0.0f, 0.0f,
    0.0f, 1.0f, 0.0f, 0.0f,
    0.0f, 0.0f, 1.0f, 0.0f,
    0.0f, 0.0f, 0.0f, 1.0f
};

#pragma mark -
#pragma mark Public - Transformations - Load

simd::float4x4 GLMGetMatrix(const bool& transpose,
                            const GLenum& name)
{
    simd::float4x4 M = 0.0f;
    
    GLfloat m[16];
    
    glGetFloatv(name, m);
    
    if(transpose)
    {
        M.columns[0] = {m[0], m[1], m[2], m[3]};
        M.columns[1] = {m[4], m[5], m[6], m[7]};
        M.columns[2] = {m[8], m[9], m[10], m[11]};
        M.columns[3] = {m[12], m[13], m[14], m[15]};
    } // if
    else
    {
        M.columns[0] = {m[0], m[4], m[8], m[12]};
        M.columns[1] = {m[1], m[5], m[9], m[13]};
        M.columns[2] = {m[2], m[6], m[10], m[14]};
        M.columns[3] = {m[3], m[7], m[11], m[15]};
    } // else
    
    return M;
} // GLMGetMatrix

simd::float4x4 GLM::modelview(const bool& transpose)
{
    return GLMGetMatrix(transpose, GL_MODELVIEW_MATRIX);
} // modelview

simd::float4x4 GLM::projection(const bool& transpose)
{
    return GLMGetMatrix(transpose, GL_PROJECTION_MATRIX);
} // projection

simd::float4x4 GLM::texture(const bool& transpose)
{
    return GLMGetMatrix(transpose, GL_TEXTURE_MATRIX);
} // texture

void GLM::load(const bool& transpose,
               const simd::float4x4& M)
{
    GLfloat m[16];
    
    if(transpose)
    {
        m[0] = M.columns[0].x;
        m[1] = M.columns[0].y;
        m[2] = M.columns[0].z;
        m[3] = M.columns[0].w;
        
        m[4] = M.columns[1].x;
        m[5] = M.columns[1].y;
        m[6] = M.columns[1].z;
        m[7] = M.columns[1].w;
        
        m[8]  = M.columns[2].x;
        m[9]  = M.columns[2].y;
        m[10] = M.columns[2].z;
        m[11] = M.columns[2].w;
        
        m[12] = M.columns[3].x;
        m[13] = M.columns[3].y;
        m[14] = M.columns[3].z;
        m[15] = M.columns[3].w;
    } // if
    else
    {
        m[0] = M.columns[0].x;
        m[1] = M.columns[1].x;
        m[2] = M.columns[2].x;
        m[3] = M.columns[3].x;
        
        m[4] = M.columns[0].y;
        m[5] = M.columns[1].y;
        m[6] = M.columns[2].y;
        m[7] = M.columns[3].y;
        
        m[8]  = M.columns[0].z;
        m[9]  = M.columns[1].z;
        m[10] = M.columns[2].z;
        m[11] = M.columns[3].z;
        
        m[12] = M.columns[0].w;
        m[13] = M.columns[1].w;
        m[14] = M.columns[2].w;
        m[15] = M.columns[3].w;
    } // else
    
    glLoadMatrixf(m);
} // load

void GLM::identity(const GLenum& mode)
{
    glMatrixMode(mode);
    
    glLoadMatrixf(kIdentity);
} // identity

#pragma mark -
#pragma mark Public - Transformations - Scale

simd::float4x4 GLM::scale(const GLfloat& x,
                          const GLfloat& y,
                          const GLfloat& z)
{
    simd::float4 v = {x, y, z, 1.0f};
    
    return simd::float4x4(v);
} // Scale

simd::float4x4 GLM::scale(const simd::float3& s)
{
    simd::float4 v = {s.x, s.y, s.z, 1.0f};
    
    return simd::float4x4(v);
} // Scale

#pragma mark -
#pragma mark Public - Transformations - Translate

simd::float4x4 GLM::translate(const simd::float3& t)
{
    simd::float4x4 M = matrix_identity_float4x4;
    
    M.columns[3].xyz = t;
    
    return M;
} // Translate

simd::float4x4 GLM::translate(const GLfloat& x,
                              const GLfloat& y,
                              const GLfloat& z)
{
    simd::float4x4 M = matrix_identity_float4x4;
    
    M.columns[3].x = x;
    M.columns[3].y = y;
    M.columns[3].z = z;
    
    return M;
} // Translate

#pragma mark -
#pragma mark Public - Transformations - Rotate

simd::float4x4 GLM::rotate(const GLfloat& angle,
                           const simd::float3& r)
{
    GLfloat a = angle / 180.0f;
    GLfloat c = 0.0f;
    GLfloat s = 0.0f;
    
    // Computes the sine and cosine of pi times angle (measured in radians)
    // faster and gives exact results for angle = 90, 180, 270, etc.
    __sincospif(a, &s, &c);
    
    GLfloat k = 1.0f - c;
    
    simd::float3 u = simd::normalize(r);
    simd::float3 v = s * u;
    simd::float3 w = k * u;
    
    simd::float4 P = 0.0f;
    simd::float4 Q = 0.0f;
    simd::float4 R = 0.0f;
    simd::float4 S = 0.0f;
    
    P.x = w.x * u.x + c;
    P.y = w.x * u.y - v.z;
    P.z = w.x * u.z + v.y;
    
    Q.x = w.y * u.x + v.z;
    Q.y = w.y * u.y + c;
    Q.z = w.y * u.z - v.x;
    
    R.x = w.z * u.x - v.y;
    R.y = w.z * u.y + v.x;
    R.z = w.z * u.z + c;
    
    S.w = 1.0f;
    
    return simd::float4x4(P, Q, R, S);
} // Rotate

simd::float4x4 GLM::rotate(const simd::float4& r)
{
    simd::float3 R = {r.x, r.y, r.z};
    
    return GLM::rotate(r.w, R);
} // Rotate

simd::float4x4 GLM::rotate(const GLfloat& angle,
                           const GLfloat& x,
                           const GLfloat& y,
                           const GLfloat& z)
{
    simd::float3 r= {x, y, z};
    
    return GLM::rotate(angle, r);
} // Rotate

#pragma mark -
#pragma mark Public - Transformations - Perspective

simd::float4x4 GLM::perspective(const GLfloat& fovy,
                                const GLfloat& aspect,
                                const GLfloat& near,
                                const GLfloat& far)
{
    
    GLfloat a = GLM::kPiDiv360_f * fovy;
    GLfloat f = 1.0f / std::tan(a);
    
    GLfloat sNear  = 2.0f * near;
    GLfloat sDepth = 1.0f / (near - far);
    
    simd::float4 P = 0.0f;
    simd::float4 Q = 0.0f;
    simd::float4 R = 0.0f;
    simd::float4 S = 0.0f;
    
    P.x =  f / aspect;
    Q.y =  f;
    R.z =  sDepth * (far + near);
    R.w = -1.0f;
    S.z =  sNear * sDepth * far;
    
    return simd::float4x4(P, Q, R, S);
} // perspective

simd::float4x4 GLM::perspective(const GLfloat& fovy,
                                const GLfloat& width,
                                const GLfloat& height,
                                const GLfloat& near,
                                const GLfloat& far)
{
    GLfloat aspect = width / height;
    
    return GLM::perspective(fovy, aspect, near, far);
} // perspective

#pragma mark -
#pragma mark Public - Transformations - Projection

simd::float4x4 GLM::projection(const GLfloat& fovy,
                               const GLfloat& aspect,
                               const GLfloat& near,
                               const GLfloat& far)
{
    GLfloat sNear = 2.0f * near;
    
    GLfloat a = GLM::kPiDiv360_f * fovy;
    GLfloat f = near * std::tan(a);
    
    GLfloat left   = -f * aspect;
    GLfloat right  =  f * aspect;
    GLfloat bottom = -f;
    GLfloat top    =  f;
    
    GLfloat sWidth  = 1.0f / (right - left);
    GLfloat sHeight = 1.0f / (top - bottom);
    GLfloat sDepth  = 1.0f / (near - far);
    
    simd::float4 P = 0.0f;
    simd::float4 Q = 0.0f;
    simd::float4 R = 0.0f;
    simd::float4 S = 0.0f;
    
    P.x =  sNear * sWidth;
    Q.y =  sNear * sHeight;
    R.z =  sDepth * (far + near);
    R.w = -1.0f;
    S.z =  sNear * sDepth * far;
    
    return simd::float4x4(P, Q, R, S);
} // projection

simd::float4x4 GLM::projection(const GLfloat& fovy,
                               const GLfloat& width,
                               const GLfloat& height,
                               const GLfloat& near,
                               const GLfloat& far)
{
    GLfloat aspect = width / height;
    
    return GLM::projection(fovy, aspect, near, far);
} // projection

#pragma mark -
#pragma mark Public - Transformations - LookAt

simd::float4x4 GLM::lookAt(const simd::float3& eye,
                           const simd::float3& center,
                           const simd::float3& up)
{
    simd::float3 E = -eye;
    simd::float3 N = simd::normalize(eye - center);
    simd::float3 U = simd::normalize(simd::cross(up, N));
    simd::float3 V = simd::cross(N, U);
    
    simd::float4 P = 0.0f;
    simd::float4 Q = 0.0f;
    simd::float4 R = 0.0f;
    simd::float4 S = 0.0f;
    
    P.x = U.x;
    P.y = U.y;
    P.z = U.z;
    P.w = simd::dot(U, E);
    
    Q.x = V.x;
    Q.y = V.y;
    Q.z = V.z;
    Q.w = simd::dot(V, E);
    
    R.x = N.x;
    R.y = N.y;
    R.z = N.z;
    R.w = simd::dot(N, E);
    
    S.w = 1.0f;
    
    return simd::float4x4(P, Q, R, S);
} // LookAt

simd::float4x4 GLM::lookAt(const GLfloat * const pEye,
                           const GLfloat * const pCenter,
                           const GLfloat * const pUp)
{
    simd::float3 eye    = {pEye[0], pEye[1], pEye[2]};
    simd::float3 center = {pCenter[0], pCenter[1], pCenter[2]};
    simd::float3 up     = {pUp[0], pUp[1], pUp[2]};
    
    return GLM::lookAt(eye, center, up);
} // lookAt

#pragma mark -
#pragma mark Public - Transformations - Orthographic

simd::float4x4 GLM::ortho(const GLfloat& left,
                          const GLfloat& right,
                          const GLfloat& bottom,
                          const GLfloat& top,
                          const GLfloat& near,
                          const GLfloat& far)
{
    GLfloat sWidth  = 1.0f / (right - left);
    GLfloat sHeight = 1.0f / (top   - bottom);
    GLfloat sDepth  = 1.0f / (far   - near);
    
    simd::float4 P = 0.0f;
    simd::float4 Q = 0.0f;
    simd::float4 R = 0.0f;
    simd::float4 S = 0.0f;
    
    P.x =  2.0f * sWidth;
    Q.y =  2.0f * sHeight;
    R.z = -2.0f * sDepth;
    S.x = -sWidth  * (right + left);
    S.y = -sHeight * (top   + bottom);
    S.z = -sDepth  * (far   + near);
    S.w =  1.0f;
    
    return simd::float4x4(P, Q, R, S);
} // Ortho

simd::float4x4 GLM::ortho(const GLfloat& left,
                          const GLfloat& right,
                          const GLfloat& bottom,
                          const GLfloat& top)
{
    return GLM::ortho(left, right, bottom, top, 0.0f, 1.0f);
} // ortho

simd::float4x4 GLM::ortho(const simd::float3& origin,
                          const simd::float3& size)
{
    return GLM::ortho(origin.x, origin.y, origin.z, size.x, size.y, size.z);
} // Ortho

#pragma mark -
#pragma mark Public - Transformations - frustum

simd::float4x4 GLM::frustum(const GLfloat& left,
                            const GLfloat& right,
                            const GLfloat& bottom,
                            const GLfloat& top,
                            const GLfloat& near,
                            const GLfloat& far)
{
    GLfloat sWidth  = 1.0f / (right - left);
    GLfloat sHeight = 1.0f / (top - bottom);
    GLfloat sDepth  = 1.0f / (near - far);
    GLfloat sNear   = 2.0f * near;
    
    simd::float4 P = 0.0f;
    simd::float4 Q = 0.0f;
    simd::float4 R = 0.0f;
    simd::float4 S = 0.0f;
    
    P.x =  sWidth  * sNear;
    P.z =  sWidth  * (right + left);
    Q.y =  sHeight * sNear;
    Q.z =  sHeight * (top + bottom);
    R.z =  sDepth  * (far + near);
    R.w =  sDepth  * sNear * far;
    S.z = -1.0f;
    
    return simd::float4x4(P, Q, R, S);
} // frustum

simd::float4x4 GLM::frustum(const GLfloat& fovy,
                            const GLfloat& aspect,
                            const GLfloat& near,
                            const GLfloat& far)
{
    const GLfloat a = GLM::kPiDiv360_f * fovy;
    const GLfloat t = near * std::tan(a);       // tan(fovy/2) = top/near
    
    GLfloat left   = 0.0f;
    GLfloat right  = 0.0f;
    GLfloat top    = 0.0f;
    GLfloat bottom = 0.0f;
    
    if(aspect >= 1.0f)
    {
        right  =  aspect * t;
        left   = -right;
        top    =  t;
        bottom = -top;
    } // if
    else
    {
        right  =  t;
        left   = -right;
        top    =  t / aspect;
        bottom = -top;
    } // else
    
    return GLM::frustum(left, right, bottom, top, near, far);
} // frustum

simd::float4x4 GLM::frustum(const GLfloat& fovy,
                            const GLfloat& width,
                            const GLfloat& heigth,
                            const GLfloat& near,
                            const GLfloat& far)
{
    const GLfloat aspect = width / heigth;
    
    return GLM::frustum(fovy, aspect, near, far);
} // frustum
