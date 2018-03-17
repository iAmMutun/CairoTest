//
//  CairoView.h
//  Cairo Test
//
//  Created by i.am.mutun on 14/3/2556.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <list>
#import "curve.h"

@interface CairoView : NSView {
  int state;
  BOOL clipboard;
  abs_curve_t clipboard_curve;
  abs_curve_t current_curve;
  double *editing_x;
  double *editing_y;
  std::list<rel_curve_t> curves;
  std::list<rel_curve_t>::iterator current_curve_it;
}
@end
