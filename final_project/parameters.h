#ifndef PARAMETERS_H
#define PARAMETERS_H

typedef struct _parameter
{
  int treeNum;
  int maxTreeDepth;
  int classNum;
  int minExampleNum;
  int sampleEmpMethod;
  float imageProportion;
  int sampleNumRoot;
  int sampleNumFirstLayer;
  int sampleNumRegular;
  float boundLimit;
  float minRegionSize;
  int siftCodebookSize;
  float maxEntropy;
  int bgPrePooling;
  int bgPyramidLevel;
  char *leafDistExample;
  int fineTuning;
} PARAMETER;

void SetParameters(PARAMETER &param);

#endif
