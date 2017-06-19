/*
 <codex>
 <abstract>
 Mediator object for managing buttons associated with N-Body simulator types.
 </abstract>
 </codex>
 */

#import <string>

#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>

@interface NBodyButtons : NSObject

@property (nonatomic, readonly) size_t   count;
@property (nonatomic, readonly) CGRect   bounds;
@property (nonatomic, readonly) CGPoint  position;

@property (nonatomic) BOOL         isVisible;
@property (nonatomic) BOOL         isSelected;
@property (nonatomic) BOOL         isItalic;
@property (nonatomic) size_t       index;
@property (nonatomic) CGFloat      fontSize;
@property (nonatomic) CGPoint      origin;
@property (nonatomic) CGSize       size;
@property (nonatomic) std::string  label;
@property (nonatomic) GLfloat      speed;

- (instancetype) initWithCount:(size_t)count;

- (BOOL) acquire;
- (void) toggle;
- (void) draw;

@end
