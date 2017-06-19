/*
 <codex>
 <abstract>
 OpenGL container type definitions.
 </abstract>
 </codex>
 */

#ifndef _OPENGL_CONTAINERS_H_
#define _OPENGL_CONTAINERS_H_

#import <ostream>
#import <regex>
#import <sstream>
#import <string>
#import <unordered_map>
#import <unordered_set>
#import <vector>

#import <OpenGL/OpenGL.h>

#ifdef __cplusplus

typedef std::string GLstring;
typedef std::regex  GLregex;

typedef std::ostream        GLostream;
typedef std::ostringstream  GLosstringstream;

typedef std::vector<GLuint>   GLuints;
typedef std::vector<GLenum>   GLenums;
typedef std::vector<GLstring> GLstrings;

typedef GLuints  GLhandles;
typedef GLuints  GLshaders;
typedef GLenums  GLtargets;

typedef std::unordered_map<GLuint, GLuint>        GLproperties;
typedef std::unordered_map<GLint, GLproperties>   GLrenderers;
typedef std::unordered_map<GLuint, GLrenderers>   GLdisplays;
typedef std::unordered_map<GLuint, GLstring>      GLpropertynames;
typedef std::unordered_map<GLenum, GLstring>      GLsources;

typedef std::unordered_set<GLstring>  GLstringset;

#endif

#endif
