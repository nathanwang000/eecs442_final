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
  mexPrintf("read %s to image vector! total size of %d\n", DataFilename, imVec.size()); // debug!!!!
  
  //GetData(imVec, DataFilenameFlipped, param); 
  //mexPrintf("read %s to image vector, total size of %d\n", DataFilenameFlipped, imVec.size()); // debug!!!!
  
  AdjustLabels(imVec, classNum);
  mexPrintf("Finish getting data from the disk.\n");

  // pre-pooling for the background information, if it is necessary
//  if (param.bgPrePooling == 1)
//    BgPrePooling(imVec, param);
//  mexPrintf("Finish getting background feature.\n");

  // the pre-allocated memory for all the trees
  int treeMemSize = int(pow(2, param.maxTreeDepth + 1)) * param.treeNum;
  TREENODE *treeMemory = new TREENODE[treeMemSize];
  InitTreeMem(treeMemory, treeMemSize);
  int treeMemID = 0; 
  vector<TREENODE*> trees;  // the set of decision trees
  for (int i = 0; i < param.treeNum; i++)
  {
    trees.push_back(treeMemory + treeMemID);
    treeMemID++;
  }
  mexPrintf("Finish initializing all the trees.\n");

  // train decision trees
  clock_t t1, t2;
  vector<int> trainID, valID;  // indicate which samples are included in the current tree node
  char filename[1024];
  float *valDist = (float*)malloc(sizeof(float) * classNum);  // sample distribution in the val set
  for (int i = 0; i < param.treeNum; i++)
  {
    t1 = clock();
    GetFilename(filename, action);
    mexPrintf("\nThe current tree will be in this file: %s\n", filename);
    trainID.clear();
    valID.clear();
    InitializeTree(trees[i]);
    int nodeID = 0;
    memset(valDist, 0, sizeof(float) * classNum);
    TrainDecisionTree(trees[i], imVec, param, trainID, valID, 
        classNum, nodeID, treeMemory, treeMemID, valDist);
//    sprintf(filename, "trees/tree_%d%d%d.txt", i / 100, (i % 100) / 10, i % 10);
    OutputTree(trees[i], filename);
    t2 = clock();
    mexPrintf("\n    Time for trainning this tree: %f\n", (float)(t2 - t1) / CLOCKS_PER_SEC);
  }

  free(valDist);
  ReleaseData(imVec);
  for (int i = 0; i < param.treeNum; i++)
    ReleaseTreeMem(trees[i]);
  delete[] treeMemory;
  
 
}
