/*
 <codex>
 <abstract>
 A base utility class for managing performance meters.
 </abstract>
 </codex>
 */

#import <string>

#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>

@interface NBodyMeter: NSObject

@property (nonatomic) BOOL         isVisible;
@property (nonatomic) BOOL         useTimer;
@property (nonatomic) BOOL         useHostInfo;
@property (nonatomic) std::string  label;
@property (nonatomic) size_t       max;
@property (nonatomic) GLsizei      bound;
@property (nonatomic) GLfloat      speed;
@property (nonatomic) GLdouble     value;
@property (nonatomic) CGSize       frame;
@property (nonatomic) CGPoint      point;

+ (instancetype) meter;

- (BOOL) acquire;
- (void) toggle;

- (void) update;
- (void) draw;

- (void) reset;

@end

