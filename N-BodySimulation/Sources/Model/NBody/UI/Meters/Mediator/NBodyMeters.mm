/*
 <codex>
 <import>NBodyMeters.h</import>
 </codex>
 */

#pragma mark -

#import <OpenGL/gl.h>

#import "GLMConstants.h"
#import "GLMTransforms.h"

#import "NBodyMeter.h"
#import "NBodyMeters.h"

@implementation NBodyMeters
{
@private
    size_t           _index;
    size_t           _count;
    NSMutableArray*  mpMeters;
    NBodyMeter*      mpMeter;
}

- (instancetype) initWithCount:(size_t)count
{
    self = [super init];
    
    if(self)
    {
        _index = 0;
        _count = count;
        
        mpMeters = [[NSMutableArray alloc] initWithCapacity:_count];
        
        if(mpMeters)
        {
            size_t i;
            
            for(i = 0; i < _count; ++i)
            {
                mpMeters[i] = [NBodyMeter meter];
            } // for
            
            mpMeter = mpMeters[_index];
        } // if
    } // if
    
    return self;
} // init

- (void) dealloc
{
    if(mpMeters)
    {
        [mpMeters release];
        
        mpMeters = nil;
    } // if
    
    [super dealloc];
} // dealloc

- (void) reset
{
    for(NBodyMeter* pMeter in mpMeters)
    {
        pMeter.value = 0.0;
        
        [pMeter reset];
    } // for
} // reset

- (void) resize:(NSSize)size
{
    for(NBodyMeter* pMeter in mpMeters)
    {
        pMeter.frame = size;
    } // for
} // resize

- (void) show:(BOOL)doShow;
{
    for(NBodyMeter* pMeter in mpMeters)
    {
        pMeter.isVisible = doShow;
    } // for
} // show

- (BOOL) acquire
{
    return [mpMeter acquire];
} // acquire

- (void) toggle
{
    [mpMeter toggle];
} // toggle

- (void) update
{
    [mpMeter update];
} // update

- (void) draw
{
    [mpMeter draw];
} // draw

- (void) draw:(NSArray *)positions
{
    if(positions)
    {
        size_t i = 0;
        
       for(NSValue* position in positions)
       {
           NBodyMeter* pMeter = mpMeters[i];
           
           pMeter.point = position.pointValue;
           
           [pMeter update];
           [pMeter draw];
           
           i++;
       } // for
    } // if
} // draw

- (GLsizei) bound
{
    return mpMeter.bound;
} // bound

- (CGSize) frame
{
    return mpMeter.frame;
} // frame

- (BOOL) useTimer
{
    return mpMeter.useTimer;
} // useTimer

- (BOOL) useHostInfo
{
    return mpMeter.useHostInfo;
} // useHostInfo

- (BOOL) isVisible
{
    return mpMeter.isVisible;
} // isVisible

- (std::string) label
{
    return mpMeter.label;
} // label

- (size_t) max
{
    return mpMeter.max;
} // max

- (CGPoint) point
{
    return mpMeter.point;
} // point

- (GLfloat) speed
{
    return mpMeter.speed;
}// speed

- (GLfloat) value
{
    return mpMeter.value;
} // value

- (void) setBound:(GLsizei)bound
{
    mpMeter.bound = bound;
} // setBound

- (void) setFrame:(CGSize)frame
{
    mpMeter.frame = frame;
} // setFrame

- (void) setUseTimer:(BOOL)useTimer
{
    mpMeter.useTimer = useTimer;
} // setUseTimer

- (void) setUseHostInfo:(BOOL)useHostInfo
{
    mpMeter.useHostInfo = useHostInfo;
} // setUseHostInfo

- (void) setIndex:(size_t)index
{
    _index = (index < _count) ? index : 0;
    
    mpMeter = mpMeters[_index];
} // setIndex

- (void) setIsVisible:(BOOL)isVisible
{
    mpMeter.isVisible = isVisible;
} // setIsVisible

- (void) setLabel:(std::string)label
{
    mpMeter.label = label;
} // setLabel

- (void) setMax:(size_t)max
{
    mpMeter.max = max;
} // setMax

- (void) setPoint:(CGPoint)point
{
    mpMeter.point = point;
} // setPoint

- (void) setSpeed:(GLfloat)speed
{
    mpMeter.speed = speed;
} // setSpeed

- (void) setValue:(GLfloat)value
{
    mpMeter.value = value;
} // setValue

@end
