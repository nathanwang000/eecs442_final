#include <cstring>
#include <fstream>
#include "feature.h"
#include "nodeclassifier.h"
#include "mex.h"
using namespace std;


// adjust the class labels so that if they don't start from 0, make them start from 0
void AdjustLabels(vector<SINGLEIM> &imVec, int &classNum)
{
  int minLabel = imVec[0].classLbl;
  int maxLabel = imVec[0].classLbl;
   int count = 0;
  for (vector<SINGLEIM>::iterator imItr = imVec.begin(); imItr < imVec.end(); imItr++)
  {
    if (minLabel > imItr->classLbl)
      minLabel = imItr->classLbl;
    if (maxLabel < imItr->classLbl)
      maxLabel = imItr->classLbl;
    
    
     count = count + 1;
  }

  classNum = maxLabel - minLabel + 1;
  mexPrintf("   maxLabel: %d\t", maxLabel); 
  mexPrintf("   minLabel: %d\t", minLabel); 
   mexPrintf("   classNum: %d\t", classNum); 
  if (minLabel == 0)
    return;

  for (vector<SINGLEIM>::iterator imItr = imVec.begin(); imItr < imVec.end(); imItr++)
    imItr->classLbl -= minLabel;
}


// Get image data from the hard drive
void GetData(vector<SINGLEIM> &imVec, char *filename, PARAMETER param)
{
  int imageNum, imArea;
  ifstream fin(filename, ios::in | ios::binary);
  fin.read((char*)&imageNum, sizeof(int));
  
  //imageNum = 10;
  // imageNum = 300;
  mexPrintf("\n    imageNum: %d\n", imageNum); /// for debugging also kyunghee
  for (int i = 0; i < imageNum; i++)
  {
    SINGLEIM im;
    fin.read((char*)&im.classLbl, sizeof(int)); // this is right
    fin.read((char*)&im.classLbl2, sizeof(int)); // this is right
    
    mexPrintf(" %d;", im.classLbl);
    if (im.classLbl != 2 && im.classLbl != 1){
        mexPrintf("\n%d invalid, exiting\n", i); // 975 here (976 in matfile) for class 151 !!!!!!!!!!!!!!!!!!!!!!!!!!
        throw 10;
    }
    // read foreground data
    fin.read((char*)&im.fgWidth, sizeof(int)); // this is right
    mexPrintf("\nfg width is %d\n", im.fgWidth);
    fin.read((char*)&im.fgHeight, sizeof(int)); // this is right
    mexPrintf("\nfg height is %d\n", im.fgHeight);
    imArea = im.fgWidth * im.fgHeight;
    
    im.fgStartID = (int*)malloc(sizeof(int) * (imArea + 1)); // this is right
    fin.read((char*)im.fgStartID, sizeof(int) * (imArea + 1)); // this is right

    im.fgCodeID = (int*)malloc(sizeof(int) * im.fgStartID[imArea]); // ok, although I don't know what it does, it seems right

    fin.read((char*)im.fgCodeID, sizeof(int) * im.fgStartID[imArea]); // this is correct if the above is correct
    int *codePTR = im.fgCodeID;
    int codeNum = im.fgStartID[imArea];
    for (int j = 0; j < codeNum; j++)
    {
      *codePTR -= 1;
      codePTR++;
    }

    im.fgValue = (float*)malloc(sizeof(float) * im.fgStartID[imArea]);
    fin.read((char*)im.fgValue, sizeof(float) * im.fgStartID[imArea]);

    // read background data
    im.bgWidth = 0;
    im.bgHeight = 0;
    im.bgStartID = NULL;
    im.bgCodeID = NULL;
    im.bgValue = NULL;
    im.bgFtrDim = 5 * param.siftCodebookSize;
    im.bgHist = (float*)malloc(sizeof(float) * im.bgFtrDim);
    fin.read((char*)im.bgHist, sizeof(float) * 4 * param.siftCodebookSize);
    float *secLayerStartPTR = im.bgHist;
    float *firLayerPTR = im.bgHist + 4 * param.siftCodebookSize;
    memset(firLayerPTR, 0, sizeof(float) * param.siftCodebookSize);
    float *secLayerPTR;
    for (int j = 0; j < param.siftCodebookSize; j++)
    {
      secLayerPTR = secLayerStartPTR;
      for (int k = 0; k < 4; k++)
      {
          
           if (j == 830 && k == 2)
             mexPrintf("\n    1 by 1 and 2 by 2: %f\n", *secLayerPTR); 
          
          
        if (*secLayerPTR > *firLayerPTR)
          *firLayerPTR = *secLayerPTR;
        secLayerPTR += param.siftCodebookSize;
      }
      firLayerPTR++;
      secLayerStartPTR++;
    }

    imVec.push_back(im);
  }

  fin.close();
}


// release the image data from the memory
void ReleaseData(vector<SINGLEIM> &imVec)
{
  for (int i = 0; i < imVec.size(); i++)
  {
    free(imVec[i].fgStartID);
    free(imVec[i].fgCodeID);
    free(imVec[i].fgValue);
    free(imVec[i].bgStartID);
    free(imVec[i].bgCodeID);
    free(imVec[i].bgValue);
    if (imVec[i].bgHist != NULL)
      free(imVec[i].bgHist);
  }
  imVec.clear();
}



void GetBgPmRegions(vector<PMREGION> &pmRegions, PARAMETER param)
{
  pmRegions.clear();
  pmRegions.push_back(PMRegion(0.0f, 0.0f, 1.0f, 1.0f));
  if (param.bgPyramidLevel > 1)
  {
    for (int i = 0; i < 2; i++)
    {
      for (int j = 0; j < 2; j++)
        pmRegions.push_back(PMRegion((float)i/2.0f, (float)j/2.0f, 0.5f, 0.5f));
    }
  }
  if (param.bgPyramidLevel > 2)
  {
    for (int i = 0; i < 4; i++)
    {
      for (int j = 0; j < 4; j++)
        pmRegions.push_back(PMRegion((float)i/4.0f, (float)j/4.0f, 0.25f, 0.25f));
    }
  }
  if (param.bgPyramidLevel > 3)
  {
    for (int i = 0; i < 8; i++)
    {
      for (int j = 0; j < 8; j++)
        pmRegions.push_back(PMRegion((float)i/8.0f, (float)j/8.0f, 0.125f, 0.125f));
    }
  }
  if (param.bgPyramidLevel > 4)
    mexErrMsgTxt("Too many background pyramid levels!\n");
}



void BgPrePooling(vector<SINGLEIM> &imVec, PARAMETER param)
{
  vector<PMREGION> pmRegions;
  GetBgPmRegions(pmRegions, param);
  int regionNum = pmRegions.size();
  for (vector<SINGLEIM>::iterator imPTR = imVec.begin(); imPTR < imVec.end(); imPTR++)
  {
    imPTR->bgFtrDim = regionNum * param.siftCodebookSize;
    imPTR->bgHist = (float*)malloc(sizeof(float) * imPTR->bgFtrDim);
    MaxPooling(*imPTR, imPTR->bgHist, pmRegions, param, "bg");
  }
}
