#include <cstring>
#include <time.h>
#include <math.h>
#include "feature.h"
#include "parameters.h"
#include "decisiontree.h"
#include "treeaccessory.h"
#include "mex.h"

// matlab entry point
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

  // input must have tree size, binary_feature_filename, binary_feature_flipped_filename, action name
  if (nrhs != 4)
    mexErrMsgTxt("Wrong number of inputs, treesize, binaryfeaturefilename, binaryfeatureflippedfilename, action_name needed"); 
  // Currently, we do not have any output
  if (nlhs != 0)
    mexErrMsgTxt("Wrong number of outputs");
  /* make sure the first input argument is scalar */
  if( !mxIsDouble(prhs[0]) || 
      mxIsComplex(prhs[0]) ||
      mxGetNumberOfElements(prhs[0])!=1 ) {
    mexErrMsgIdAndTxt("MyToolbox:arrayProduct:notScalar",
                      "Input tree size must be a scalar.");
  }
  /* input must be a string */
  if ( mxIsChar(prhs[1]) != 1 || mxIsChar(prhs[2]) != 1 || mxIsChar(prhs[3]) != 1 )
      mexErrMsgIdAndTxt( "MATLAB:revord:inputNotString",
                         "Input must be a string.");
  // read in input string
  char *DataFilename, *DataFilenameFlipped, *action;
  DataFilename = mxArrayToString(prhs[1]);
  DataFilenameFlipped = mxArrayToString(prhs[2]);
  action = mxArrayToString(prhs[3]);
  
  // set the seed for random numbers
  srand(time(NULL));

  mexPrintf("Entered dttrain.cpp!\n"); // debug!!!!
  // set parameters for learning
  PARAMETER param;
  SetParameters(param);
  param.treeNum = mxGetScalar(prhs[0]); // treat tree num specially
  mexPrintf("tree num is %d\n", param.treeNum); // debug!!!!

  mexPrintf("parameters set!\n"); // debug!!!!

  // get image feature descriptors from the file
  vector<SINGLEIM> imVec;
  int classNum;
  
  // use filename passed in here!!!
  GetData(imVec, DataFilename, param); 
  mexPrintf("read %s to image vector!", DataFilename); // debug!!!!
  mexPrintf("totalsize of", imVec.size()); // debug!!!!
  
  GetData(imVec, DataFilenameFlipped, param); 
  mexPrintf("read %s to image vector, total size of %d\n", DataFilenameFlipped, imVec.size()); // debug!!!!
  
  AdjustLabels(imVec, classNum);
  mexPrintf("Finish getting data from the disk.\n");
 
}
