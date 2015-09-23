#ifndef FEATURE_H
#define FEATURE_H

#include <iostream>
#include <vector>
#include "parameters.h"
using namespace std;

typedef struct _single_im
{
  int classLbl, classLbl2;
  int fgWidth, bgWidth;
  int fgHeight, bgHeight;
  int *fgStartID, *bgStartID;
  int *fgCodeID, *bgCodeID;
  float *fgValue, *bgValue;
  int bgFtrDim;  // "bgFtrDim" and "bgHist" is meaning if and only if param.bgPrePool == 1
  float *bgHist;
} SINGLEIM;

template <class T>
void CopyVector(vector<T> &dst, vector<T> src)
{
  dst.clear();
  for (int i = 0; i < src.size(); i++)
    dst.push_back(src[i]);
}

void GetData(vector<SINGLEIM> &imVec, char *filename, PARAMETER param);
void ReleaseData(vector<SINGLEIM> &imVec);
void BgPrePooling(vector<SINGLEIM> &imVec, PARAMETER param);
void AdjustLabels(vector<SINGLEIM> &imVec, int &classNum);

#endif
