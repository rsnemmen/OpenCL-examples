/*
 <codex>
 <import>NBodyMeter.h</import>
 </codex>
 */

#import <OpenGL/gl.h>

#import "CFCPULoad.h"

#import "GLMConstants.h"
#import "GLMTransforms.h"

#import "HUDMeterImage.h"
#import "HUDMeterTimer.h"

#import "NBodyMeter.h"

static const GLfloat kDefaultSpeed = 0.06f;

@implementation NBodyMeter
{
@private
    BOOL  _isVisible;
    BOOL  _useTimer;
    BOOL  _useHostInfo;
    
    size_t   _max;
    GLsizei  _bound;
    GLfloat  _speed;
    CGSize   _frame;
    CGPoint  _point;
    
    std::string  _label;
    
    BOOL mbStart;
    
    GLfloat mnPosition;
    
    HUD::Meter::Image* mpMeter;
    HUD::Meter::Timer* mpTimer;
    
    CF::CPU::Load* mpLoad;
}

- (instancetype) init
{
    self = [super init];
    
    if(self)
    {
        _isVisible   = YES;
        _useTimer    = NO;
        _useHostInfo = NO;
        
        _speed = kDefaultSpeed;
        _bound = 0;
        _max   = 0;
        _frame = NSMakeSize(0.0f, 0.0f);
        _point = NSMakePoint(0.0f, 0.0f);
        _label = "";
        
        mbStart    = NO;
        mnPosition = 0.0f;
        
        mpMeter = nullptr;
        mpTimer = nullptr;
        mpLoad  = nullptr;
    } // if
    
    return self;
} // initWithBound

+ (instancetype) meter
{
    return [[[NBodyMeter allocWithZone:[self zone]] init] autorelease];
} // meterWithBound

- (void) dealloc
{
    if(mpTimer != nullptr)
    {
        delete mpTimer;
        
        mpTimer = nullptr;
    } // if
    
    if(mpMeter != nullptr)
    {
        delete mpMeter;
        
        mpMeter = nullptr;
    } // if
    
    if(mpLoad != nullptr)
    {
        delete mpLoad;
        
        mpLoad = nullptr;
    } // if
    
    if(!_label.empty())
    {
        _label.clear();
    } // if
    
    [super dealloc];
} // dealloc

- (void) setFrame:(CGSize)frame
{
    if((frame.width > 0.0f) && (frame.height > 0.0f))
    {
        _frame = frame;
    } // if
} // setFrame

- (void) setIsVisible:(BOOL)isVisible
{
    _isVisible = isVisible;
} // setIsVisible

- (void) setLabel:(std::string)label
{
    if(!label.empty())
    {
        _label = label;
    } // if
} // setLabel

- (void) setValue:(GLdouble)value
{
    mpMeter->setTarget(value);
} // setValue

- (GLdouble) value
{
    return mpMeter->target();
} // value

- (void) toggle
{
    _isVisible = !_isVisible;
} // toggle

- (BOOL) acquire
{
    if(_useHostInfo)
    {
        mpLoad = new (std::nothrow) CF::CPU::Load;
        
        if(!mpLoad)
        {
            NSLog(@">> ERROR: Failed acquiring a CPU utilization query object!");
            
            return false;
        } // if
    } // if
    
    if(_useTimer)
    {
        mpTimer = new (std::nothrow) HUD::Meter::Timer(20, false);
        
        if(!mpTimer)
        {
            NSLog(@">> ERROR: Failed acquiring a hi-res timer for the meters!");
            
            return false;
        } // if
    } // if
    
    mpMeter = new (std::nothrow) HUD::Meter::Image(_bound, _bound, _max, _label);
    
    if(!mpMeter)
    {
        NSLog(@">> ERROR: Failed acquiring a meter object!");
        
        return false;
    } // if
    
    return true;
} // acquire

- (void) reset
{
    if(_useTimer)
    {
        mpTimer->reset();
    } // if
} // reset

- (void) update
{
    if(_useTimer)
    {
        if(!mbStart)
        {
            mpTimer->start();
            
            mbStart = YES;
        } // if
        else
        {
            mpTimer->stop();
            mpTimer->update();
            
            mpMeter->setTarget(mpTimer->persecond());
            
            mpTimer->reset();
        } // else
    } // if
    
    if(_useHostInfo)
    {
        GLdouble nPercentage = mpLoad->percentage();
        
        GLdouble nTargetSrc = mpMeter->target();
        GLdouble nTargetDst = 0.01 * nPercentage + 0.99 * nTargetSrc;
        
        mpMeter->setTarget(nTargetDst);
    } // if
    
    mpMeter->update();
} // update

- (void) draw
{
    glMatrixMode(GL_PROJECTION);
    
    GLM::load(true, GLM::ortho(0.0f, _frame.width, 0.0f, _frame.height, -1.0f, 1.0f));
    
    GLM::identity(GL_MODELVIEW);
    
    if(_isVisible)
    {
        if(mnPosition <= (GLM::kHalfPi_f - _speed))
        {
            mnPosition += _speed;
        } // if
    } // if
    else if(mnPosition > 0.0f)
    {
        mnPosition -= _speed;
    } // else if
    
    GLfloat y = 416.0f * (1.0f - std::sin(mnPosition));
    
    GLM::load(true, GLM::translate(0.0f, y, 0.0f));
    
    if(mnPosition > 0.0f)
    {
        mpMeter->draw(_point.x, _frame.height - _point.y);
    } // if
    
    GLM::identity(GL_MODELVIEW);
} // draw

@end