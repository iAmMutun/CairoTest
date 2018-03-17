#include "curve.h"

rel_curve_t abs2rel_curve(abs_curve_t abs_curve)
{
  rel_curve_t rel_curve;
  rel_curve.x = abs_curve.x1;
  rel_curve.y = abs_curve.y1;
  rel_curve.dx = abs_curve.x2 - abs_curve.x1;
  rel_curve.dy = abs_curve.y2 - abs_curve.y1;
  rel_curve.hx1 = abs_curve.hx1 - abs_curve.x1;
  rel_curve.hy1 = abs_curve.hy1 - abs_curve.y1;
  rel_curve.hx2 = abs_curve.hx2 - abs_curve.x1;
  rel_curve.hy2 = abs_curve.hy2 - abs_curve.y1;
  return rel_curve;
}

abs_curve_t rel2abs_curve(rel_curve_t rel_curve)
{
  abs_curve_t abs_curve;
  abs_curve.x1 = rel_curve.x;
  abs_curve.y1 = rel_curve.y;
  abs_curve.x2 = rel_curve.x + rel_curve.dx;
  abs_curve.y2 = rel_curve.y + rel_curve.dy;
  abs_curve.hx1 = rel_curve.x + rel_curve.hx1;
  abs_curve.hy1 = rel_curve.y + rel_curve.hy1;
  abs_curve.hx2 = rel_curve.x + rel_curve.hx2;
  abs_curve.hy2 = rel_curve.y + rel_curve.hy2;
  return abs_curve;
}
