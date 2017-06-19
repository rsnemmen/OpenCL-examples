/*
 <codex>
 <abstract>
 Utility  class for managing a button associated with N-Body simulator.
 </abstract>
 </codex>
 */

#import <string>

#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>

@interface NBodyButton : NSObject

@property (nonatomic, readonly) CGRect   bounds;
@property (nonatomic, readonly) CGPoint  position;

@property (nonatomic) BOOL         isVisible;
@property (nonatomic) BOOL         isSelected;
@property (nonatomic) BOOL         isItalic;
@property (nonatomic) CGFloat      fontSize;
@property (nonatomic) CGPoint      origin;
@property (nonatomic) CGSize       size;
@property (nonatomic) std::string  label;
@property (nonatomic) GLfloat      speed;

+ (instancetype) button;

- (BOOL) acquire;
- (void) toggle;
- (void) draw;

@end
