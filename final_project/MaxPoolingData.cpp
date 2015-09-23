#include <math.h>
#include <string.h>
#include "mex.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    // nrhs is the input, nlhs is the output
    double *data = (double*)mxGetPr(prhs[0]);
    //const int *dataDim = mxGetDimensions(data);
    const int *dataDim = mxGetDimensions(prhs[0]);
    //int oriWidth = mxGetScalar(mxGetPr(prhs[1]));
    //int oriHeight = mxGetScalar(mxGetPr(prhs[2]));
    int oriWidth = (int)mxGetScalar(prhs[1]);
    int oriHeight = (int)mxGetScalar(prhs[2]);
    
    int width = (int)((float)oriWidth / 2 + 0.5);
    int height = (int)((float)oriHeight/ 2 + 0.5);
    int out[2];
    out[0] = width * height;
    out[1] = dataDim[1];
    
    mxArray *mxPoolData = mxCreateNumericArray(2, out, mxDOUBLE_CLASS, mxREAL);
    double *poolData = (double*)mxGetPr(mxPoolData);
    memset(poolData, 0, out[0] * out[1] * sizeof(double));
 
    /*
    plhs[0] = mxCreateNumericArray(2, out, mxDOUBLE_CLASS, mxREAL);
    double *poolData = (double*)mxGetPr(plhs[0]);
    memset(poolData, 0, out[0] * out[1] * sizeof(double));
    */
    
    double *poolDataStartPTR = poolData;
    for (int h = 0; h < height; h++)
    {
        for (int w = 0; w < width; w++)
        {
            int ID = 2 * h * oriWidth + 2 * w;
            if (ID < dataDim[0])
            {
                double *poolDataPTR = poolDataStartPTR;
                double *dataPTR = data + ID;
                for (int i = 0; i < dataDim[1]; i++)
                {
                    if (*dataPTR > *poolDataPTR)
                        *poolDataPTR = *dataPTR;
                    dataPTR += dataDim[0];
                    poolDataPTR += out[0];
                }
            }
            
            ID = 2 * h * oriWidth + 2 * w + 1;
            if (ID < dataDim[0])
            {
                double *poolDataPTR = poolDataStartPTR;
                double *dataPTR = data + ID;
                for (int i = 0; i < dataDim[1]; i++)
                {
                    if (*dataPTR > *poolDataPTR)
                        *poolDataPTR = *dataPTR;
                    dataPTR += dataDim[0];
                    poolDataPTR += out[0];
                }
            }
            
            ID = (2 * h + 1) * oriWidth + 2 * w;
            if (ID < dataDim[0])
            {
                double *poolDataPTR = poolDataStartPTR;
                double *dataPTR = data + ID;
                for (int i = 0; i < dataDim[1]; i++)
                {
                    if (*dataPTR > *poolDataPTR)
                        *poolDataPTR = *dataPTR;
                    dataPTR += dataDim[0];
                    poolDataPTR += out[0];
                }
            }
            
            ID = (2 * h + 1) * oriWidth + 2 * w + 1;
            if (ID < dataDim[0])
            {
                double *poolDataPTR = poolDataStartPTR;
                double *dataPTR = data + ID;
                for (int i = 0; i < dataDim[1]; i++)
                {
                    if (*dataPTR > *poolDataPTR)
                        *poolDataPTR = *dataPTR;
                    dataPTR += dataDim[0];
                    
                }
            }
            
            poolDataStartPTR++;
        }
    }
}
