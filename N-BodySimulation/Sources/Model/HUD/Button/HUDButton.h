/*
 <codex>
 <abstract>
 Utility class for generating a button in an OpenGL view.
 </abstract>
 </codex>
 */


#ifndef _HUD_BUTTON_H_
#define _HUD_BUTTON_H_

#import <string>

#import "GLUQuad.h"
#import "GLUText.h"

#ifdef __cplusplus

namespace HUD
{
    namespace Button
    {
        typedef std::string Label;
        typedef CGPoint     Position;
        typedef CGRect      Bounds;
        
        enum Tracking
        {
            eNothing,
            ePressed,
            eUnpressed,
        };
        
        class Image
        {
        public:
            Image(const Bounds& frame,
                  const CGFloat& size = 24.0f);
            
            Image(const Bounds& frame,
                  const CGFloat& size,
                  const bool& italic,
                  const Label& label);
            
            virtual ~Image();
            
            bool setLabel(const Label& label);
            
            void draw(const bool& selected,
                      const Position& position,
                      const Bounds& bounds);
            
        private:
            bool          mbIsItalic;
            GLuint        m_Texture[2];
            GLdouble      mnSize;
            GLsizei       mnWidth;
            GLsizei       mnHeight;
            Label         m_Label;
            GLU::QuadRef  mpQuad;
            GLU::Text    *mpText;
        }; // Image
    } // Button
} // HUD

#endif

#endif
