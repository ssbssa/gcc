/* PR 89807 */
/* { dg-do compile } */
/* { dg-options "-Wconversion -Wsign-conversion" } */
/* { dg-require-effective-target int32plus } */

void shift(unsigned long long ull, unsigned int ui, unsigned short us,
	   unsigned char uc)
{
  signed char c;
  short s;
  int i;
  long long ll;

  c = ull >> 56; /* { dg-warning "conversion" } */
  c = ull >> 57;
  c = ui >> 24; /* { dg-warning "conversion" } */
  c = ui >> 25;
  c = us >> 8; /* { dg-warning "conversion" } */
  c = us >> 9;
  c = uc >> 1;

  s = ull >> 48; /* { dg-warning "conversion" } */
  s = ull >> 49;
  s = ui >> 16; /* { dg-warning "conversion" } */
  s = ui >> 17;
  s = us >> 1;

  i = ull >> 32; /* { dg-warning "conversion" } */
  i = ull >> 33;
  i = ui >> 1;

  ll = ull >> 1;

  uc = ull >> 55; /* { dg-warning "conversion" } */
  uc = ull >> 56;
  uc = ui >> 23; /* { dg-warning "conversion" } */
  uc = ui >> 24;
  uc = us >> 7; /* { dg-warning "conversion" } */
  uc = us >> 8;

  us = ull >> 47; /* { dg-warning "conversion" } */
  us = ull >> 48;
  us = ui >> 15; /* { dg-warning "conversion" } */
  us = ui >> 16;

  ui = ull >> 31; /* { dg-warning "conversion" } */
  ui = ull >> 32;
}
