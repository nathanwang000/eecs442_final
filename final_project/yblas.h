#ifndef _YBLAS_H_
#define _YBLAS_H_

double dnrm2_(int *n, double *x, int *incx);
double ddot_(int *n, double *sx, int *incx, double *sy, int *incy);
int daxpy_(int *n, double *sa, double *sx, int *incx, double *sy, int *incy);
int dscal_(int *n, double *sa, double *sx, int *incx);

#endif
