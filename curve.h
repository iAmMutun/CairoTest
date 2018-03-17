#ifndef _CURVE
#define _CURVE

#include "cairo.h"
#ifdef __cplusplus
extern "C" {
#endif

struct abs_curve_t {
  double x1, y1;
  double x2, y2;
  double hx1, hy1;
  double hx2, hy2;
};

typedef struct abs_curve_t
abs_curve_t;

struct rel_curve_t {
  double x, y;
  double dx, dy;
  double hx1, hy1;
  double hx2, hy2;
};

typedef struct rel_curve_t
rel_curve_t;

#if defined(USE_ABSOLUTE) && defined(USE_RELATIVE)
#error "USE_ABSOLUTE and USE_RELATIVE must not be both defined at the same time"
#endif

#ifdef USE_ABSOLUTE
typedef abs_curve_t
curve_t;
#endif

#ifdef USE_RELATIVE
typedef rel_curve_t
curve_t;
#endif

abs_curve_t rel2abs_curve(rel_curve_t rel_curve);
rel_curve_t abs2rel_curve(abs_curve_t abs_curve);

#ifdef __cplusplus
}
#endif
  
#endif