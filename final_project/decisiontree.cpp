#include <cstring>
#include <time.h>
#include <math.h>
#include "decisiontree.h"
#include "linear.h"
#include "mex.h"


// initialize the root node of the tree
void InitializeTree(TREENODE *treeNode)
{
  treeNode->nodeID = 0;
  treeNode->depth = 0;
}



void SwapLabels(vector<SINGLEIM> &imVec)
{
  for (vector<SINGLEIM>::iterator imPTR = imVec.begin(); imPTR < imVec.end(); imPTR++)
  {
    if (imPTR->classLbl2 == -1)
      continue;

    int flag = rand() % 2;
    if (flag == 0)
      swap(imPTR->classLbl, imPTR->classLbl2);
  }
}



// generate samples for the current tree, when we train the root node
void GenerateSamples(vector<SINGLEIM> imVec, PARAMETER param,
    vector<int> &trainID, vector<int> &valID)
{
  trainID.clear();
  valID.clear();

  if (param.sampleEmpMethod == 0)
  {
    // sample "imageProportion" of the whole images, duplication is not allowed
    vector<int> tmpID;
    int imageNum = imVec.size();
    for (int i = 0; i < imageNum; i++)
      tmpID.push_back(i);

    int sampleNum = (int)(param.imageProportion * imageNum + 0.5);
    int sampleID;
    for (int i = 0; i < sampleNum; i++)
    {
      sampleID = rand() % tmpID.size();
      trainID.push_back(tmpID[sampleID]);
      tmpID.erase(tmpID.begin() + sampleID);
    }

    for (vector<int>::iterator idPTR = tmpID.begin(); idPTR < tmpID.end(); idPTR++)
      valID.push_back(*idPTR);
  }
  else if (param.sampleEmpMethod == 1)
  {
    // sample the same number of examples for each class for training, duplication is not allowed
    // calculate the number of images for training in each class
    int *imageNum = (int*)malloc(sizeof(int) * param.classNum);
    memset(imageNum, 0, sizeof(int) * param.classNum);
    for (vector<SINGLEIM>::iterator imPTR = imVec.begin(); imPTR < imVec.end(); imPTR++)
      *(imageNum + imPTR->classLbl) += 1;
    
    // [ywchao]
    // int sampleNumPerClass;
    // if (imageNum[0] >= imageNum[1])
    //     sampleNumPerClass = imageNum[1];
    // else
    //     sampleNumPerClass = imageNum[0];
    // mexPrintf(" sampled: %d\n",sampleNumPerClass);
    
    int sampleNumPerClass[2];
    if (imageNum[0] > 500)
        sampleNumPerClass[0] = 500;
    else
        sampleNumPerClass[0] = imageNum[0];
    if (imageNum[1] > 500)
        sampleNumPerClass[1] = 500;
    else
        sampleNumPerClass[1] = imageNum[1];
    mexPrintf(" pos samples: %d\n",sampleNumPerClass[0]);
    mexPrintf(" neg samples: %d\n",sampleNumPerClass[1]);
    //int sampleNumPerClass = (int)((imVec.size() / param.classNum) * param.imageProportion + 0.5);
    //for (int i = 0; i < param.classNum; i++)
    //{
    //  if (imageNum[i] < sampleNumPerClass)
    //    mexErrMsgTxt("The image proportion parameter is too large!");
    //} 
    free(imageNum);

    vector<int> tmpID;
    for (int i = 0; i < param.classNum; i++)
    {
      // for each class ...
      tmpID.clear();  // the ID of the images whose label is "i" will be in "tmpID"
      int count = 0;
      for (vector<SINGLEIM>::iterator imPTR = imVec.begin(); imPTR < imVec.end(); imPTR++)
      {
        if (imPTR->classLbl == i)
          tmpID.push_back(count);
        count++;
      }

      int sampleID;
      // [ywchao]
      // for (int j = 0; j < sampleNumPerClass; j++)
      for (int j = 0; j < sampleNumPerClass[i]; j++)
      {
        sampleID = rand() % tmpID.size();
        trainID.push_back(tmpID[sampleID]);
        tmpID.erase(tmpID.begin() + sampleID);
      }

      for (vector<int>::iterator idPTR = tmpID.begin(); idPTR < tmpID.end(); idPTR++)
        valID.push_back(*idPTR);
    }
  }
  else if (param.sampleEmpMethod == 2)
  {
    vector<int> tmpID;
    int imageNum = imVec.size() / 2;
    for (int i = 0; i < imageNum; i++)
      tmpID.push_back(i);

    int sampleNum = (int)(param.imageProportion * imageNum + 0.5);
    int sampleID;
    for (int i = 0; i < sampleNum; i++)
    {
      sampleID = rand() % tmpID.size();
      trainID.push_back(tmpID[sampleID]);
      trainID.push_back(tmpID[sampleID] + imageNum);  // this is the corresponding flipped image
      tmpID.erase(tmpID.begin() + sampleID);
    }

    for (vector<int>::iterator idPTR = tmpID.begin(); idPTR < tmpID.end(); idPTR++)
    {
      valID.push_back(*idPTR);
      valID.push_back(*idPTR + imageNum);
    }
  }
  else
    mexErrMsgTxt("The specified method for sampling images has not been implemented yet!\n");
}



void GetValDist(vector<SINGLEIM> imVec, vector<int> valID, float *valDist, int classNum)
{
  memset(valDist, 0, sizeof(float) * classNum);
  for (vector<int>::iterator idPTR = valID.begin(); idPTR < valID.end(); idPTR++)
    *(valDist + imVec[*idPTR].classLbl) += 1;

  float *valDistPTR = valDist;
  int valNum = valID.size();
  for (int i = 0; i < classNum; i++)
  {
    *valDist /= valNum;
    valDist++;
  }
}



// how many classes of examples that the current node still have?
int GetUniqueClassNum(vector<SINGLEIM> imVec, vector<int> trainID, vector<int> &classID)
{
  // the classID of all the samples in the current node
  classID.clear();
  for (vector<int>::iterator idPTR = trainID.begin(); idPTR < trainID.end(); idPTR++)
    classID.push_back(imVec[*idPTR].classLbl);

  // deduplication
  for (vector<int>::iterator idPTR = classID.begin(); idPTR < classID.end(); idPTR++)
  {
    for (vector<int>::iterator compPTR = classID.end() - 1; compPTR > idPTR; compPTR--)
    {
      if (*idPTR == *compPTR)
        classID.erase(compPTR);
    }
  }
}



// get the distribution of the samples for the leaf node
void GetLeafNodeDist(float *distribution, vector<SINGLEIM> imVec, vector<int> trainID, 
    vector<int> valID, float *valDist, int classNum, char *leafDistExample)
{
  memset(distribution, 0, sizeof(float) * classNum);

  if (strcmp(leafDistExample, "train") == 0)
  {
    if (trainID.size() == 0)
      return;
    for (vector<int>::iterator idPTR = trainID.begin(); idPTR < trainID.end(); idPTR++)
      *(distribution + imVec[*idPTR].classLbl) += 1;
    for (int i = 0; i < classNum; i++)
      distribution[i] /= trainID.size();
  }
  else if (strcmp(leafDistExample, "val") == 0)
  {
    if (valID.size() == 0)
      return;
    for (vector<int>::iterator idPTR = valID.begin(); idPTR < valID.end(); idPTR++)
      *(distribution + imVec[*idPTR].classLbl) += 1;

    float ttlValue = 0.0f;
    for (int i = 0; i < classNum; i++)  // normalize the distribution based on the
    {
      if (valDist[i] != 0)
        distribution[i] /= valDist[i];    //   number of val images for each class
      ttlValue += distribution[i];
    }
    for (int i = 0; i < classNum; i++)
      distribution[i] /= ttlValue;
  }
  else if (strcmp(leafDistExample, "all") == 0)
  {
    int totalNum = trainID.size() + valID.size();
    if (totalNum == 0)
      return;
    for (vector<int>::iterator idPTR = trainID.begin(); idPTR < trainID.end(); idPTR++)
      *(distribution + imVec[*idPTR].classLbl) += 1;
    for (vector<int>::iterator idPTR = valID.begin(); idPTR < valID.end(); idPTR++)
      *(distribution + imVec[*idPTR].classLbl) += 1;
    for (int i = 0; i < classNum; i++)
      distribution[i] /= totalNum;
  }
  else
    mexErrMsgTxt("Invalid param.leafDistExample\n");
}



void GetCurrentClassID(vector<SINGLEIM> imVec, vector<int> trainID, 
    vector<int> &classID, int classNum)
{
  classID.clear();
  for (int i = 0; i < classNum; i++)
  {
    for (vector<int>::iterator imPTR = trainID.begin(); imPTR < trainID.end(); imPTR++)
    {
      if (imVec[*imPTR].classLbl == i)
      {
        classID.push_back(i);
        break;
      }
    }
  }
}



// randomly split the training classes into two subclasses;
// the two subclasses are indicated by vector trainClassID
void BinarizeLabel(vector<int> classID, vector<SINGLEIM> imVec, vector<int> trainID,
    vector<int> &trainClassID, vector<int> valID, vector<int> &valClassID)
{
  
//   // [ywchao]
//   int trainNum = trainID.size();
//   for (int i = 0; i < trainNum; i++)
//     trainClassID.push_back(-1);
//   int valNum = valID.size();
//   for (int i = 0; i < valNum; i++)
//     valClassID.push_back(-1);
//     
//   int j = 0;
//   for (vector<int>::iterator imPTR = trainID.begin(); imPTR < trainID.end(); imPTR++)
//   {
//       if (imVec[*imPTR].classLbl == 0)
//           trainClassID[j] = 1;
//       if (imVec[*imPTR].classLbl == 1)
//           trainClassID[j] = -1;
//       j++;
//   }
//   j = 0;
//   for (vector<int>::iterator imPTR = valID.begin(); imPTR < valID.end(); imPTR++)
//   {
//       if (imVec[*imPTR].classLbl == 0)
//           valClassID[j] = 1;
//       if (imVec[*imPTR].classLbl == 1)
//           valClassID[j] = -1;
//       j++;
//   }

  // initialize all trainClassID values to "-1"
  int trainNum = trainID.size();
  for (int i = 0; i < trainNum; i++)
    trainClassID.push_back(-1);
  int valNum = valID.size();
  for (int i = 0; i < valNum; i++)
    valClassID.push_back(-1);

  // set labels of the examples from half of the classes to 0
  int randNum = classID.size() / 2;
  //int randNum = rand() % (classID.size()-1)+1;
  //int randNum = randomnumber % (classID.size()-1)+1;
   mexPrintf(" %d\t", randNum);  
   
   mexPrintf(" %d\t", classID.size()); 
   mexPrintf(" random number\n"); 
  for (int i = 0; i < randNum; i++)
  {
    int ID = rand() % classID.size();
    int label = classID[ID];
    classID.erase(classID.begin() + ID);

    int j = 0;
    for (vector<int>::iterator imPTR = trainID.begin(); imPTR < trainID.end(); imPTR++)
    {
      if (imVec[*imPTR].classLbl == label)
        trainClassID[j] = 0;
      j++;
    }
    j = 0;
    for (vector<int>::iterator imPTR = valID.begin(); imPTR < valID.end(); imPTR++)
    {
      if (imVec[*imPTR].classLbl == label)
        valClassID[j] = 0;
      j++;
    }
  }

  // set labels of the other half classes to 1
  for (int i = 0; i < classID.size(); i++)
  {
    int label = classID[i];

    int j = 0;
    for (vector<int>::iterator imPTR = trainID.begin(); imPTR < trainID.end(); imPTR++)
    {
      if (imVec[*imPTR].classLbl == label)
        trainClassID[j] = 1;
      j++;
    }
    j = 0;
    for (vector<int>::iterator imPTR = valID.begin(); imPTR < valID.end(); imPTR++)
    {
      if (imVec[*imPTR].classLbl == label)
        valClassID[j] = 1;
      j++;
    }
  }
}



// train decision trees
// trainID stores the index of all the training examples for the current tree node.
// valID stores the index of the examples that fall into the current tree node but not in the 
//   training set. they are used to evaluate the performance of the sampled features.
void TrainDecisionTree(TREENODE *treeNode, vector<SINGLEIM> imVec, 
    PARAMETER param, vector<int> trainID, vector<int> valID, int classNum, 
    int &nodeID, TREENODE *treeMemory, int &treeMemID, float *valDist)
{
  mexPrintf("  Training node: %d\n", nodeID);
  treeNode->classNum = classNum;
  // if the current node is the root node, then randomly generate
  //   a set of samples for the current node to train
  if (treeNode->depth == 0)
  {
    nodeID = 0;
    SwapLabels(imVec);
    GenerateSamples(imVec, param, trainID, valID);
    mexPrintf("  %d\n",trainID.size());
    GetValDist(imVec, valID, valDist, classNum);
  }

  // if the current node is the leaf node, then exist
  vector<int> classID;
  GetCurrentClassID(imVec, trainID, classID, classNum);
  
  // [ywchao]
  // mexPrintf("%d\n",classID.size());
  // for (int i; i < classID.size(); ++i)
  //   mexPrintf("%d\n",classID[i]);
  // mexPrintf("%d\n",classNum);
  
  if ((treeNode->depth >= param.maxTreeDepth) || (trainID.size() <= param.minExampleNum)
      || (classID.size() < 2))
  {
//    mexPrintf("  Node %d is a leaf node\n", treeNode->nodeID);
    treeNode->ftrX = 0.0f;
    treeNode->ftrY = 0.0f;
    treeNode->ftrWid = 0.0f;
    treeNode->ftrHgt = 0.0f;
    treeNode->pmRegions.clear();
    treeNode->ftrDim = 0;
    treeNode->ftrWeight = NULL;
    treeNode->labelDist = (float*)malloc(sizeof(float) * classNum);
    GetLeafNodeDist(treeNode->labelDist, imVec, trainID, valID, 
        valDist, classNum, param.leafDistExample);
    treeNode->lchild = NULL;
    treeNode->rchild = NULL;
    treeNode->lchildID = -1;
    treeNode->rchildID = -1;
    classID.clear();
    return;
  }

  // trainClassID will be a vector of "0" or "1" values
  //   indicating training situations for the current node.
  // otherClassID is the same thing for the examples in "otherID"
  //   otherClassID is set to -1 if the class label is not in classID.
  vector<int> trainClassID;
  vector<int> valClassID;
  BinarizeLabel(classID, imVec, trainID, trainClassID, valID, valClassID);
  classID.clear();

  // [ywchao]
  // for (int i = 0; i < trainID.size(); ++i)
  //    mexPrintf(" %d\n",trainClassID[i]);
  
  int sampleNum;
  if (treeNode->depth == 0)
    sampleNum = param.sampleNumRoot;
  else if (treeNode->depth == 1)
    sampleNum = param.sampleNumFirstLayer;
  else
    sampleNum = param.sampleNumRegular;

  // for the current node, sample a number
  float infoGain = 0.0f, maxInfoGain = -99.9f;
  float ftrX, ftrY, ftrWid, ftrHgt;
  int ftrDim;
  vector<PMREGION> regions;
  float *ftrWeight, *bestFtrWeight;
  ftrWeight = (float*)malloc(sizeof(float) * (100 * param.siftCodebookSize + 1)); // 65=(1+4+16)*2
  bestFtrWeight = (float*)malloc(sizeof(float) * (100 * param.siftCodebookSize + 1));
  vector<int> leftTrainID, rightTrainID, bestLeftTrainID, bestRightTrainID;
  vector<int> leftValID, rightValID, bestLeftValID, bestRightValID;

  for (int i = 0; i < sampleNum; i++)
  {
    ftrWid = (float)rand() * (1 - param.minRegionSize) / (float)RAND_MAX + param.minRegionSize;
    ftrHgt = (float)rand() * (1 - param.minRegionSize) / (float)RAND_MAX + param.minRegionSize;
    ftrX = (float)rand() * (1 - ftrWid) / (float)RAND_MAX;
    ftrY = (float)rand() * (1 - ftrHgt) / (float)RAND_MAX;

    // "imID" and "otherID" are indications of the examples.
    // "trainClassID" and "otherClassID" are binary label assignments for those examples.
    infoGain = TrainCurrentRegion(ftrX, ftrY, ftrWid, ftrHgt, ftrDim, 
        ftrWeight, imVec, trainClassID, trainID, valClassID, valID, 
        param, leftTrainID, rightTrainID, leftValID, rightValID, regions);

    if (infoGain > maxInfoGain)
    {
      mexPrintf("    x = %f, y = %f, wid = %f, hgt = %f,  infoGain = %f\n",
          ftrX, ftrY, ftrWid, ftrHgt, infoGain);
      maxInfoGain = infoGain;
      treeNode->ftrX = ftrX;
      treeNode->ftrY = ftrY;
      treeNode->ftrWid = ftrWid;
      treeNode->ftrHgt = ftrHgt;
      treeNode->ftrDim = ftrDim;
      CopyVector<PMREGION>(treeNode->pmRegions, regions);
      memcpy(bestFtrWeight, ftrWeight, sizeof(float) * ftrDim);
      CopyVector<int>(bestLeftTrainID, leftTrainID);
      CopyVector<int>(bestRightTrainID, rightTrainID);
      CopyVector<int>(bestLeftValID, leftValID);
      CopyVector<int>(bestRightValID, rightValID);
    }

    if (maxInfoGain >= param.maxEntropy)
      break;
  }

  mexPrintf(" start fine tuning\n");
  // do the fine tuning
  if ((param.fineTuning == 1) && (maxInfoGain < param.maxEntropy))
  {
    float tmpFtrX = treeNode->ftrX;
    float tmpFtrY = treeNode->ftrY;
    for (int shiftY = -1; shiftY <= 1; shiftY++)
    {
      for (int shiftX = -1; shiftX <= 1; shiftX++)
      {
        if ((shiftX == 0) && (shiftY == 0))
          continue;
        ftrX = tmpFtrX + shiftX * 0.05;
        ftrY = tmpFtrY + shiftY * 0.05;
        if ((ftrX < 0) || (ftrX + treeNode->ftrWid > 1) 
            || (ftrY < 0) || (ftrY + treeNode->ftrHgt > 1))
          continue;

        infoGain = TrainCurrentRegion(ftrX, ftrY, treeNode->ftrWid, treeNode->ftrHgt, 
            ftrDim, ftrWeight, imVec, trainClassID, trainID, valClassID, valID,
            param, leftTrainID, rightTrainID, leftValID, rightValID, regions);

        if (infoGain > maxInfoGain)
        {
          mexPrintf("    fine tuning: x = %f, y = %f, wid = %f, hgt = %f, infoGain = %f\n",
              ftrX, ftrY, treeNode->ftrWid, treeNode->ftrHgt, infoGain);
          maxInfoGain = infoGain;
          treeNode->ftrX = ftrX;
          treeNode->ftrY = ftrY;
          treeNode->ftrDim = ftrDim;
          CopyVector<PMREGION>(treeNode->pmRegions, regions);
          memcpy(bestFtrWeight, ftrWeight, sizeof(float) * ftrDim);
          CopyVector<int>(bestLeftTrainID, leftTrainID);
          CopyVector<int>(bestRightTrainID, rightTrainID);
          CopyVector<int>(bestLeftValID, leftValID);
          CopyVector<int>(bestRightValID, rightValID);
        }
      }
    }
  }

  treeNode->ftrWeight = (float*)malloc(sizeof(float) * treeNode->ftrDim);
  memcpy(treeNode->ftrWeight, bestFtrWeight, sizeof(float) * treeNode->ftrDim);
  treeNode->labelDist = NULL;


  // depth and nodeID are assigned in the parent node or initialization
  // train the current node's left child
  treeNode->lchild = treeMemory + treeMemID;
  treeMemID++;
  treeNode->lchild->depth = treeNode->depth + 1;
  nodeID++;
  treeNode->lchild->nodeID = nodeID;
  treeNode->lchildID = nodeID;
  TrainDecisionTree(treeNode->lchild, imVec, param, bestLeftTrainID,
      bestLeftValID, classNum, nodeID, treeMemory, treeMemID, valDist);

  // train the current node's right child
  treeNode->rchild = treeMemory + treeMemID;
  treeMemID++;
  treeNode->rchild->depth = treeNode->depth + 1;
  nodeID++;
  treeNode->rchild->nodeID = nodeID;
  treeNode->rchildID = nodeID;
  TrainDecisionTree(treeNode->rchild, imVec, param, bestRightTrainID,
      bestRightValID, classNum, nodeID, treeMemory, treeMemID, valDist);

  trainClassID.clear();
  valClassID.clear();
  regions.clear();
  free(ftrWeight);
  free(bestFtrWeight);
  leftTrainID.clear();
  rightTrainID.clear();
  bestLeftTrainID.clear();
  bestRightTrainID.clear();
  leftValID.clear();
  rightValID.clear();
  bestLeftValID.clear();
  bestRightValID.clear();
}



void DecisionTreeClassify(SINGLEIM image, TREENODE *treeNode, float *result, PARAMETER param)
{
  if (treeNode->lchild == NULL)  // reaches the leaf node
  {
    memcpy(result, treeNode->labelDist, sizeof(float) * treeNode->classNum);
//    mexPrintf("  Ground truth label: %d.  ", image.classLbl);
//    for (int i = 0; i < treeNode->classNum; i++)
//      mexPrintf("%d:%d, ", i, (int)(treeNode->labelDist[i]));
//    if (treeNode->labelDist[image.classLbl] > 0.5)
//      mexPrintf("  Correct.");
//    mexPrintf("\n");
    return;
  }

  // classify using the current tree node
  float *feature = (float*)malloc(sizeof(float) * treeNode->ftrDim);
  MaxPooling(image, feature, treeNode->pmRegions, param, "fg");  // foreground feature
  memcpy(feature + treeNode->pmRegions.size() * param.siftCodebookSize, 
      image.bgHist, sizeof(float) * image.bgFtrDim);
  *(feature + treeNode->ftrDim - 1) = 0.1f;

  float *featurePTR = feature;
  float *weightPTR = treeNode->ftrWeight;
  float score = 0.0f;
  for (int i = 0; i < treeNode->ftrDim; i++)
  {
    if (*featurePTR > 0)
      score += *featurePTR * *weightPTR;
    featurePTR++;
    weightPTR++;
  }
//  mexPrintf("  Score of node %d is %f\n", treeNode->nodeID, score);

  free(feature);
  if (score > 0)
    DecisionTreeClassify(image, treeNode->lchild, result, param);
  else
    DecisionTreeClassify(image, treeNode->rchild, result, param);
}



// using the current decision tree to classify all images
// the result will be added up to that in "result"
void TestDecisionTree(vector<SINGLEIM> imVec, TREENODE *tree, float *result, PARAMETER param, int classNum_test) // classNum_test added myself
{
  // debug!!!!!!!!!!!!
  mexPrintf("classNum_train:%d, classNum_test:%d", tree->classNum, classNum_test);
  // tree->classNum = classNum_test;
  int classNum = tree->classNum; // different class num compared to testing
  // end debugging
  
  float * singleResult = NULL; // a distribution of labels of size clasNum x 1
  singleResult = (float*)malloc(sizeof(float) * classNum);
  float *resultPTR = result;
  int count = 0;
  for (vector<SINGLEIM>::iterator imPTR = imVec.begin(); imPTR < imVec.end(); imPTR++)
  {
    memset(singleResult, 0, sizeof(float) * classNum);
    DecisionTreeClassify(*imPTR, tree, singleResult, param);

    for (int i = 0; i < classNum; i++)
      *(resultPTR + i * imVec.size()) += *(singleResult + i);
    resultPTR++;
  }
  if (singleResult != NULL) // only when it is set we free it
    free(singleResult); 
  singleResult=NULL; // best practice
}

