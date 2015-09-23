#include "parameters.h"
#include <string.h>

void SetParameters(PARAMETER &param)
{
  param.treeNum = 100;  // the number of decision trees, dummy here, taken over in the main function
  param.maxTreeDepth = 10;  // the maximum tree depth
  param.classNum = 2;  // the number of classes was 11
  param.minExampleNum = 40;  // the minimum number of examples in the node
  param.sampleEmpMethod = 1;  // the method to sample images for the root node;
                              // 0: sample "imageProportion" of the whole images, duplication is not allowed
  param.imageProportion = 0.8;
  param.sampleNumRoot = 100; // is 30 paper
  param.sampleNumFirstLayer = 100; // is 50 in paper
  param.sampleNumRegular = 100; // is 100 in paper
  
  param.minRegionSize = 0.4;  // the size of the region shouldn't be smaller than 0.1*0.1
  param.siftCodebookSize = 1024;  // the size of the SIFT codebook
  param.maxEntropy = 0.0f;  // if the entropy value for the current node is this value, 
                         //   we do not need to sample the other features any more
  param.bgPrePooling = 1;  // if we pre-pooling the background information to a 2-layer(0,1,2) spatial pyramid
  param.bgPyramidLevel = 2;  // pyramid levels of background information
  param.leafDistExample = strdup("train");  // based on which set of examples to compute the distribution of leaf node
  param.fineTuning = 1;
}
