/*
 <codex>
 <abstract>
 OpenGL view class with idle timer and fullscreen mode support.
 </abstract>
 </codex>
 */

#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>

@interface OpenGLView : NSOpenGLView

- (IBAction) toggleHelp:(id)sender;
- (IBAction) toggleFullscreen:(id)sender;

@end
