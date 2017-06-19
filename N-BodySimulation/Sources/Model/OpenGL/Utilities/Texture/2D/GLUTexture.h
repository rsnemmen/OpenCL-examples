/*
 <codex>
 <abstract>
 Utility methods for creating 2D OpenGL textures.
 </abstract>
 </codex>
 */

#ifndef _OPENGL_UTILITY_TEXTURE_H_
#define _OPENGL_UTILITY_TEXTURE_H_

#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>

#import "CGBitmap.h"

#ifdef __cplusplus

namespace GLU
{
    class Texture
    {
    public:
        Texture(CFStringRef   pName,
                CFStringRef   pExt,
                const GLenum& nTarget = GL_TEXTURE_2D,
                const bool&   bMipmap = true);
        
        Texture(const Texture& rTexture);

        virtual ~Texture();
        
        Texture& operator=(const Texture& rTexture);

        void enable();
        void disable();
        
        const GLuint& texture() const;
        const GLenum& target()  const;
    
    private:
        bool         mbMipmaps;
        GLuint       mnTexture;
        GLenum       mnTarget;
        GLsizei      mnWidth;
        GLsizei      mnHeight;
        CG::Bitmap  *mpBitmap;
    }; // Texture
} // GLU

#endif

#endif

