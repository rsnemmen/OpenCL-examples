/*
 <codex>
 <import>GLMSizes.h</import>
 </codex>
 */

#import "GLMSizes.h"

#define GLSizeChar           sizeof(GLchar)
#define GLSizeChrPtr         sizeof(GLchar *)
#define GLSizeFloat          sizeof(GLfloat)
#define GLSizeDouble         sizeof(GLdouble)
#define GLSizeSignedByte     sizeof(GLbyte)
#define GLSizeSignedBytePtr  sizeof(GLbyte *)
#define GLSizeSignedShort    sizeof(GLshort)
#define GLSizeSignedInt      sizeof(GLint)
#define GLSizeUnsignedByte   sizeof(GLubyte)
#define GLSizeUnsignedShort  sizeof(GLushort)
#define GLSizeUnsignedInt    sizeof(GLuint)
#define GLSizeLong           sizeof(long)
#define GLSizeULong          sizeof(unsigned long)

GLuint GLM::Size::kByte    = GLSizeSignedByte;
GLuint GLM::Size::kBytePtr = GLSizeSignedBytePtr;
GLuint GLM::Size::kChar    = GLSizeChar;
GLuint GLM::Size::kCharPtr = GLSizeChrPtr;
GLuint GLM::Size::kFloat   = GLSizeFloat;
GLuint GLM::Size::kHFloat  = GLSizeFloat / 2;
GLuint GLM::Size::kDouble  = GLSizeDouble;
GLuint GLM::Size::kShort   = GLSizeSignedShort;
GLuint GLM::Size::kInt     = GLSizeSignedInt;
GLuint GLM::Size::kLong    = GLSizeLong;
GLuint GLM::Size::kUByte   = GLSizeUnsignedByte;
GLuint GLM::Size::kUInt    = GLSizeUnsignedInt;
GLuint GLM::Size::kULong   = GLSizeULong;
GLuint GLM::Size::kUShort  = GLSizeUnsignedShort;
