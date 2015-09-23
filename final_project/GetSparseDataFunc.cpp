#include "mex.h"
#include <string.h>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  double *data = (double*)mxGetPr(prhs[0]);

  const int *dataDim = mxGetDimensions(prhs[0]);
  int sampleNum = dataDim[0];
  int codeNum = dataDim[1];

  int tmpVecLen = sampleNum * codeNum * 100;
  int *tmpCodeIndex = (int*)malloc(sizeof(int) * tmpVecLen);
  int *codeIndexPTR = tmpCodeIndex;
  float *tmpLLCValue = (float*)malloc(sizeof(float) * tmpVecLen);
  float *LLCValuePTR = tmpLLCValue;
  int count = 0;

  double *dataStartPTR = data;
  for (int i = 0; i < sampleNum; i++)
  {
    double *dataPTR = dataStartPTR;
    for (int j = 0; j < codeNum; j++)
    {
      if (*dataPTR != 0)
      {
        count++;
        *codeIndexPTR = j + 1;
        codeIndexPTR++;
        *LLCValuePTR = *dataPTR;
        LLCValuePTR++;
      }
      dataPTR += sampleNum;
    }
    dataStartPTR++;
  }

  int out[2];
  out[0] = 1;
  out[1] = count;
  plhs[0] = mxCreateNumericArray(2, out, mxINT32_CLASS, mxREAL);
  int *codeIndex = (int*)mxGetPr(plhs[0]);
  memcpy(codeIndex, tmpCodeIndex, count * sizeof(int));

  plhs[1] = mxCreateNumericArray(2, out, mxSINGLE_CLASS, mxREAL);
  float *LLCValue = (float*)mxGetPr(plhs[1]);
  memcpy(LLCValue, tmpLLCValue, count * sizeof(float));

  free(tmpCodeIndex);
  free(tmpLLCValue);
}
