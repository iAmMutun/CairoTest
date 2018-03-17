//
//  CairoView.m
//  Cairo Test
//
//  Created by i.am.mutun on 14/3/2556.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <cairo.h>
#import <cairo-quartz.h>
#import "CairoView.h"


@implementation CairoView

- (id)initWithFrame:(NSRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    clipboard = NO;
    state = 0;
  }
  return self;
}

-(BOOL) acceptsFirstResponder
{
  return YES;
}

- (void)cut:(id)sender
{
  if (state == 5) {
    clipboard = YES;
    clipboard_curve = current_curve;
    curves.erase(current_curve_it);
    current_curve_it = curves.end();
    state = 0;
  }
  [self setNeedsDisplay:YES];
}

- (void)copy:(id)sender
{
  if (state == 5) {
    clipboard = YES;
    rel_curve_t temp_curve = abs2rel_curve(current_curve);
    temp_curve.x += 10;
    temp_curve.y += 10;
    clipboard_curve = rel2abs_curve(temp_curve);
  }
  [self setNeedsDisplay:YES];
}

- (void)paste:(id)sender
{
  if (state == 0 || state == 1 || state == 5) {
    current_curve = clipboard_curve;
    curves.push_back(abs2rel_curve(clipboard_curve));
    current_curve_it = --curves.end();
    state = 5;
  }
  [self setNeedsDisplay:YES];
}

- (void)delete:(id)sender
{
  if (state == 5) {
    curves.erase(current_curve_it);
    current_curve_it = curves.end();
    state = 0;
  }
  [self setNeedsDisplay:YES];
}

- (void)keyDown:(NSEvent *)theEvent
{
  if([theEvent keyCode] == 51)
    [self delete:nil];
}

- (BOOL)validateMenuItem:(NSMenuItem *)theMenuItem
{
  SEL theAction = [theMenuItem action];
  
  if (theAction == @selector(copy:) || theAction == @selector(cut:) || theAction == @selector(delete:)) {
    return (state == 5);
  } else if (theAction == @selector(paste:)) {
    return (clipboard);
  }
  return NO;
}

- (void)mouseDown:(NSEvent *)theEvent {
  NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
  point.y = ([self bounds].size.height - point.y);
  if (state == 0 || state == 1 || state == 5) {
    
    cairo_surface_t *surface;
    cairo_t *cr;
    CGRect rect = (CGRect)[self bounds];
    surface = cairo_image_surface_create (CAIRO_FORMAT_ARGB32, rect.size.width, rect.size.height);
    cr = cairo_create (surface);
    
    if (state == 5) {
      abs_curve_t &curve = current_curve;
      do {
        cairo_save(cr);
        cairo_rectangle(cr, curve.x1 - 2, curve.y1 - 2, 5, 5);
        if (cairo_in_fill(cr, point.x, point.y)) {
          editing_x = &curve.x1;
          editing_y = &curve.y1;
          state = 7;
          break;
        }
        cairo_restore(cr);
        
        cairo_save(cr);
        cairo_rectangle(cr, curve.x2 - 2, curve.y2 - 2, 5, 5);
        if (cairo_in_fill(cr, point.x, point.y)) {
          editing_x = &curve.x2;
          editing_y = &curve.y2;
          state = 7;
          break;
        }
        cairo_restore(cr);
        
        cairo_save(cr);
        cairo_rectangle(cr, curve.hx1 - 2, curve.hy1 - 2, 5, 5);
        if (cairo_in_fill(cr, point.x, point.y)) {
          editing_x = &curve.hx1;
          editing_y = &curve.hy1;
          state = 7;
          break;
        }
        cairo_restore(cr);
        
        cairo_save(cr);
        cairo_rectangle(cr, curve.hx2 - 2, curve.hy2 - 2, 5, 5);
        if (cairo_in_fill(cr, point.x, point.y)) {
          editing_x = &curve.hx2;
          editing_y = &curve.hy2;
          state = 7;
          break;
        }
        cairo_restore(cr);

        cairo_save(cr);
        cairo_set_line_width (cr, 5);
        cairo_move_to(cr, curve.x1, curve.y1);
        cairo_curve_to(cr, curve.hx1, curve.hy1, curve.hx2, curve.hy2, curve.x2, curve.y2);
        if (cairo_in_stroke(cr, point.x, point.y)) {
          state = 6;
          break;
        }

        current_curve_it = curves.end();
        state = 0;
      }
      while(false);
      cairo_restore(cr);
    } else {
      current_curve_it = curves.end();
      state = 0;
    }
    if (state == 0) {
      
      std::list<rel_curve_t>::iterator it;
      cairo_set_line_width (cr, 9);
      for (it = curves.begin(); it != curves.end(); it++) {
        cairo_save(cr);
        rel_curve_t *curve = &(*it);
        cairo_move_to(cr, curve->x, curve->y);
        cairo_rel_curve_to(cr, curve->hx1, curve->hy1, curve->hx2, curve->hy2, curve->dx, curve->dy);
        if (cairo_in_stroke(cr, point.x, point.y)) {
          current_curve_it = it;
          current_curve = rel2abs_curve(*current_curve_it);
          state = 5;
          cairo_restore(cr);
          break;
        }
        cairo_restore(cr);
      }
    }
    cairo_destroy(cr);
    cairo_surface_destroy (surface);
  }
  if (state == 0) {
    state = 1;
  } else if (state == 3) {
    state = 4;
    current_curve.x2 = point.x;
    current_curve.y2 = point.y;
    current_curve.hx2 = point.x;
    current_curve.hy2 = point.y;
  }
  [self setNeedsDisplay:YES];
}

- (void)mouseDragged:(NSEvent *)theEvent {
  NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
  point.y = ([self bounds].size.height - point.y);
  if (state == 1) {
    curves.push_back(rel_curve_t());
    current_curve_it = --curves.end();
    current_curve.x1 = point.x;
    current_curve.y1 = point.y;
    current_curve.x2 = point.x;
    current_curve.y2 = point.y;
    current_curve.hx1 = point.x;
    current_curve.hy1 = point.y;
    current_curve.hx2 = point.x;
    current_curve.hy2 = point.y;
    state = 2;
  }
  if (state == 2) {
    current_curve.hx1 = point.x;
    current_curve.hy1 = point.y;
  } else if (state == 4) {
    rel_curve_t temp_curve = abs2rel_curve(current_curve);
    temp_curve.hx2 -= [theEvent deltaX];
    temp_curve.hy2 -= [theEvent deltaY];
    current_curve = rel2abs_curve(temp_curve);
  } else if (state == 6) {
    rel_curve_t temp_curve = abs2rel_curve(current_curve);
    temp_curve.x += [theEvent deltaX];
    temp_curve.y += [theEvent deltaY];
    current_curve = rel2abs_curve(temp_curve);
  } else if (state == 7) {
    *editing_x += [theEvent deltaX];
    *editing_y += [theEvent deltaY];
  }
  [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)theEvent {
  if (state == 2) {
    state = 3;
  } else if (state == 4) {
    *current_curve_it = abs2rel_curve(current_curve);
    abs_curve_t temp_curve = current_curve;

    curves.push_back(rel_curve_t());
    current_curve_it = --curves.end();
    current_curve.x1 = temp_curve.x2;
    current_curve.y1 = temp_curve.y2;
    current_curve.x2 = temp_curve.x2;
    current_curve.y2 = temp_curve.y2;
    current_curve.hx1 = temp_curve.x2 - (temp_curve.hx2 - temp_curve.x2);
    current_curve.hy1 = temp_curve.y2 - (temp_curve.hy2 - temp_curve.y2);
    current_curve.hx2 = temp_curve.x2;
    current_curve.hy2 = temp_curve.y2;
    state = 3;
  } else if (state == 6 || state == 7) {
    *current_curve_it = abs2rel_curve(current_curve);
    state = 5;
  }
  [self setNeedsDisplay:YES];
}

- (void)rightMouseDown:(NSEvent *)theEvent {
  if (state == 3) {
    NSLog(@"Tests");
    state = 0;
  }
  [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
  
  NSGraphicsContext* currentContext = [NSGraphicsContext currentContext];
  CGContextRef context = (CGContextRef)[currentContext graphicsPort];

  CGRect rect = (CGRect)[self bounds];

  CGContextTranslateCTM (context, 0.0, rect.size.height);
  CGContextScaleCTM (context, 1.0, -1.0);;

  cairo_surface_t *surface = cairo_quartz_surface_create_for_cg_context (context, rect.size.width, rect.size.height);
  cairo_t *cr = cairo_create (surface);

  cairo_set_source_rgb(cr, 0, 0, 0);
  cairo_paint (cr);
  
  std::list<rel_curve_t>::iterator it;
  cairo_set_line_width (cr, 3);
  cairo_set_source_rgb (cr, 1, 1, 1);
  for (it = curves.begin(); it != curves.end(); it++) {
    if (it != current_curve_it) {
      rel_curve_t *curve = &(*it);
      cairo_move_to(cr, curve->x, curve->y);
      cairo_rel_curve_to(cr, curve->hx1, curve->hy1, curve->hx2, curve->hy2, curve->dx, curve->dy);
    }
    cairo_stroke(cr);
  }

  if (state > 1) {
    abs_curve_t &curve = current_curve;
    if (state > 3) {
      cairo_set_line_width (cr, 3);
      cairo_set_source_rgb (cr, 1, 1, 1);
      cairo_move_to(cr, curve.x1, curve.y1);
      cairo_curve_to(cr, curve.hx1, curve.hy1, curve.hx2, curve.hy2, curve.x2, curve.y2);
      cairo_stroke(cr);

      cairo_set_line_width (cr, 1);
      cairo_set_source_rgb (cr, .5, .75, 1);
      cairo_move_to(cr, curve.x2,  curve.y2);
      cairo_line_to(cr, curve.hx2, curve.hy2);
      cairo_stroke(cr);
      cairo_rectangle(cr, curve.x2 - 1,  curve.y2 - 1, 3, 3);
      cairo_rectangle(cr, curve.hx2 - 1, curve.hy2 - 1, 3, 3);
      cairo_fill(cr);
    }

    cairo_set_line_width (cr, 1);
    cairo_set_source_rgb (cr, .5, .75, 1);
    cairo_move_to(cr, curve.x1,  curve.y1);
    cairo_line_to(cr, curve.hx1, curve.hy1);
    cairo_stroke(cr);
    cairo_rectangle(cr, curve.x1 - 1,  curve.y1 - 1, 3, 3);
    cairo_rectangle(cr, curve.hx1 - 1, curve.hy1 - 1, 3, 3);
    cairo_fill(cr);
  }

  cairo_destroy (cr);
  cairo_surface_destroy (surface);
}
@end
