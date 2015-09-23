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
  // must have the input of which action of the form board_airplane
  if (nrhs != 2)
    mexErrMsgTxt("Wrong inputs: need testfilename, action_name"); 
  // output final learned tree, class 1 label vec, class 2 label vec
  if (nlhs != 3)
    mexErrMsgTxt("Wrong number of outputs");
 /* input must be a string */
  if ( mxIsChar(prhs[0]) != 1 || mxIsChar(prhs[1]) != 1)
      mexErrMsgIdAndTxt( "MATLAB:revord:inputNotString",
                         "Input must be a string.");
  // read in input string
  char *DataFilename, *action;
  DataFilename = mxArrayToString(prhs[0]);
  action = mxArrayToString(prhs[1]);
  
  // set the seed for random numbers
  srand(time(NULL));

  mexPrintf("Entered dttest\n");
  
  // set parameters for learning
  PARAMETER param;
  SetParameters(param);
  mexPrintf("Finish setting up the parameters!\n");

  // get image feature descriptors from the file
  vector<SINGLEIM> imVec;
  int classNum;
 
  // read testfilename
  GetData(imVec, DataFilename, param);
  
  AdjustLabels(imVec, classNum);
  mexPrintf("Finish getting feature descriptors from the file!\n");

  // pre-pooling for the background information, if it is necessary
  //  if (param.bgPrePooling == 1)
  //    BgPrePooling(imVec, param);

  // the pre-allocated memory for all the trees
  int treeNum = GetTreeNum(action);
  int treeMemSize = int(pow(2, param.maxTreeDepth + 1)) * treeNum;
  TREENODE *treeMemory = new TREENODE[treeMemSize];
  InitTreeMem(treeMemory, treeMemSize);
  mexPrintf("Finish initializing tree memory.\n");
  vector<TREENODE*> trees;  // the set of decision trees
  ReadTrees(trees, treeMemory, treeNum, param, action);
  treeNum = trees.size();  // the final number of valid trees

  // treeNum = 84; 
  mexPrintf("Finish reading trees from the memory!\n");

  // debug Hard coding!!!
  classNum = 2;

  int out[3];
  out[0] = imVec.size();  // the number of imagesg
  out[1] = classNum;      // the number of classes
  out[2] = treeNum;       // the number of trees
  // create the return matrix
  plhs[0] = mxCreateNumericArray(3, out, mxSINGLE_CLASS, mxREAL);
  float *result = (float*)mxGetPr(plhs[0]);
  memset(result, 0, sizeof(float) * out[0] * out[1] * out[2]);
  float *resultPTR = result;
  for (int i = 0; i < treeNum; i++)
  {
    mexPrintf("Evaluating using the %d-th tree.\n", i);
    // initial the result with that from the previous trees
    if (i > 0)
      memcpy(resultPTR, resultPTR - out[0] * out[1], sizeof(float) * out[0] * out[1]);

    TestDecisionTree(imVec, trees[i], resultPTR, param, classNum);
    resultPTR += out[0] * out[1];
  }

  // the second output is the class label
  int classOut[2];
  classOut[0] = imVec.size();
  classOut[1] = 1;
  plhs[1] = mxCreateNumericArray(2, classOut, mxINT32_CLASS, mxREAL);
  int *classLabel1 = (int*)mxGetPr(plhs[1]);
  plhs[2] = mxCreateNumericArray(2, classOut, mxINT32_CLASS, mxREAL);
  int *classLabel2 = (int*)mxGetPr(plhs[2]);

  for (int i = 0; i < imVec.size(); i++)
  {
    classLabel1[i] = imVec[i].classLbl + 1;
    classLabel2[i] = imVec[i].classLbl2 + 1;
  }

  ReleaseData(imVec); // this is causing much trouble
  for (int i = 0; i < treeNum; i++)
    ReleaseTreeMem(trees[i]);
  delete[] treeMemory;
  
}
