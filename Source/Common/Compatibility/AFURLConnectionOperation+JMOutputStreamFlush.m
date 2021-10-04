#import "AFURLConnectionOperation+JMOutputStreamFlush.h"

@implementation AFURLConnectionOperation (JMOutputStreamFlush)

- (void)flushOutputStream;
{
  if (!self.outputStream)
    return;
  
  [self.outputStream close];
  NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
  for (NSString *runLoopMode in self.runLoopModes) {
    [self.outputStream removeFromRunLoop:runLoop forMode:runLoopMode];
  }
}

@end
