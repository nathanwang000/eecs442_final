#include <cstring>
#include "nodeclassifier.h"
#include "math.h"
#include "time.h"
#include "linear.h"
#include "mex.h"


void GetPmRegionConfig(float ftrX, float ftrY, float ftrWid,
    float ftrHgt, vector<PMREGION> &pmRegions)
{
  pmRegions.clear();

  int ID1, ID2, ID3, ID4, ID5;
  int randID = rand() % 2;
  ID1 = (randID == 0) ? 2 : 3;
  randID = rand() % 2;
  ID2 = (randID == 0) ? 2 : 3;
  randID = rand() % 2;
  ID3 = (randID == 0) ? 2 : 3;
  randID = rand() % 2;
  ID4 = (randID == 0) ? 4 : 6;
  randID = rand() % 2;
  ID5 = (randID == 0) ? 4 : 6;

  if (ftrWid < 0.4)
  {
    if (ftrHgt < 0.4)
      pmRegions.push_back(PMRegion(ftrX, ftrY, ftrWid, ftrHgt));
    else if (ftrHgt < 0.8)
    {
      pmRegions.push_back(PMRegion(ftrX, ftrY, ftrWid, ftrHgt));
      for (int i = 0; i < ID1; i++)
        pmRegions.push_back(PMRegion(ftrX, ftrY + ftrHgt*i/ID1, ftrWid, ftrHgt/ID1));
    }
    else
    {
      pmRegions.push_back(PMRegion(ftrX, ftrY, ftrWid, ftrHgt));
      for (int i = 0; i < ID1; i++)
        pmRegions.push_back(PMRegion(ftrX, ftrY + ftrHgt*i/ID1, ftrWid, ftrHgt/ID1));
      for (int i = 0; i < ID4; i++)
        pmRegions.push_back(PMRegion(ftrX, ftrY + ftrHgt*i/ID4, ftrWid, ftrHgt/ID4));
    }
  }
  else if (ftrWid < 0.8)
  {
    if (ftrHgt < 0.4)
    {
      pmRegions.push_back(PMRegion(ftrX, ftrY, ftrWid, ftrHgt));
      for (int i = 0; i < ID1; i++)
        pmRegions.push_back(PMRegion(ftrX + ftrWid*i/ID1, ftrY, ftrWid/ID1, ftrHgt));
    }
    else if (ftrHgt < 0.8)
    {
      pmRegions.push_back(PMRegion(ftrX, ftrY, ftrWid, ftrHgt));
      for (int i = 0; i < ID1; i++)
      {
        for (int j = 0; j < ID2; j++)
          pmRegions.push_back(PMRegion(ftrX + ftrWid*i/ID1, 
              ftrY + ftrHgt*j/ID2, ftrWid/ID1, ftrHgt/ID2));
      }
    }
    else
    {
      pmRegions.push_back(PMRegion(ftrX, ftrY, ftrWid, ftrHgt));
      for (int i = 0; i < ID1; i++)
      {
        for (int j = 0; j < ID2; j++)
          pmRegions.push_back(PMRegion(ftrX + ftrWid*i/ID1, 
              ftrY + ftrHgt*j/ID2, ftrWid/ID1, ftrHgt/ID2));
      }
      for (int i = 0; i < ID3; i++)
      {
        for (int j = 0; j < ID4; j++)
          pmRegions.push_back(PMRegion(ftrX + ftrWid*i/ID3, 
              ftrY + ftrHgt*j/ID4, ftrWid/ID3, ftrHgt/ID4));
      }
    }
  }
  else
  {
    if (ftrHgt < 0.4)
    {
      pmRegions.push_back(PMRegion(ftrX, ftrY, ftrWid, ftrHgt));
      for (int i = 0; i < ID1; i++)
        pmRegions.push_back(PMRegion(ftrX + ftrWid*i/ID1, ftrY, ftrWid/ID1, ftrHgt));
      for (int i = 0; i < ID4; i++)
        pmRegions.push_back(PMRegion(ftrX + ftrWid*i/ID4, ftrY, ftrWid/ID4, ftrHgt));
    }
    else if (ftrHgt < 0.8)
    {
      pmRegions.push_back(PMRegion(ftrX, ftrY, ftrWid, ftrHgt));
      for (int i = 0; i < ID1; i++)
      {
        for (int j = 0; j < ID2; j++)
          pmRegions.push_back(PMRegion(ftrX + ftrWid*i/ID1, 
              ftrY + ftrHgt*j/ID2, ftrWid/ID1, ftrHgt/ID2));
      }
      for (int i = 0; i < ID4; i++)
      {
        for (int j = 0; j < ID3; j++)
          pmRegions.push_back(PMRegion(ftrX + ftrWid*i/ID4, 
              ftrY + ftrHgt*j/ID3, ftrWid/ID4, ftrHgt/ID3));
      }
    }
    else
    {
      pmRegions.push_back(PMRegion(ftrX, ftrY, ftrWid, ftrHgt));
      for (int i = 0; i < ID1; i++)
      {
        for (int j = 0; j < ID2; j++)
          pmRegions.push_back(PMRegion(ftrX + ftrWid*i/ID1, 
              ftrY + ftrHgt*j/ID2, ftrWid/ID1, ftrHgt/ID2));
      }
      for (int i = 0; i < ID4; i++)
      {
        for (int j = 0; j < ID5; j++)
          pmRegions.push_back(PMRegion(ftrX + ftrWid*i/ID4, 
              ftrY + ftrHgt*j/ID5, ftrWid/ID4, ftrHgt/ID5));
      }
    }
  }
}






void FgMaxPooling(SINGLEIM im, float *feature, PMREGION region)
{
  int regionX = (int)(region.x * im.fgWidth + 0.5);
  int regionY = (int)(region.y * im.fgHeight + 0.5);
  int regionWid = (int)(region.wid * im.fgWidth + 0.5);
  if (regionX + regionWid > im.fgWidth)
    regionWid = im.fgWidth - regionX;
  int regionHgt = (int)(region.hgt * im.fgHeight + 0.5);
  if (regionY + regionHgt > im.fgHeight)
    regionHgt = im.fgHeight - regionY;

  int *sid = im.fgStartID + regionY * im.fgWidth + regionX;
  for (int y = 0; y < regionHgt; y++)
  {
    int startID = *sid;
    int endID = *(sid + regionWid);

    int *codePTR = im.fgCodeID + startID;
    float *valuePTR = im.fgValue + startID;
    for (int i = startID; i < endID; i++)
    {
      if (*valuePTR > *(feature + *codePTR))
        *(feature + *codePTR) = *valuePTR;
      codePTR++;
      valuePTR++;
    }

    sid += im.fgWidth;
  }
}



void BgMaxPooling(SINGLEIM im, float *feature, PMREGION region)
{
  int regionX = (int)(region.x * im.bgWidth + 0.5);
  int regionY = (int)(region.y * im.bgHeight + 0.5);
  int regionWid = (int)(region.wid * im.bgWidth + 0.5);
  if (regionX + regionWid > im.bgWidth)
    regionWid = im.bgWidth - regionX;
  int regionHgt = (int)(region.hgt * im.bgHeight + 0.5);
  if (regionY + regionHgt > im.bgHeight)
    regionHgt = im.bgHeight - regionY;

  int *sid = im.bgStartID + regionY * im.bgWidth + regionX;
  for (int y = 0; y < regionHgt; y++)
  {
    int startID = *sid;
    int endID = *(sid + regionWid);

    int *codePTR = im.bgCodeID + startID;
    float *valuePTR = im.bgValue + startID;
    for (int i = startID; i < endID; i++)
    {
      if (*valuePTR > *(feature + *codePTR))
        *(feature + *codePTR) = *valuePTR;
      codePTR++;
      valuePTR++;
    }

    sid += im.bgWidth;
  }
}



// max-pooling
void MaxPooling(SINGLEIM im, float *feature, vector<PMREGION> pmRegions, 
    PARAMETER param, char *ground)
{
  memset(feature, 0, sizeof(float) * pmRegions.size() * param.siftCodebookSize);
  float *ftrPTR = feature;
  for (vector<PMREGION>::iterator prPTR = pmRegions.begin(); prPTR < pmRegions.end(); prPTR++)
  {
    if (strcmp(ground, "fg") == 0)
      FgMaxPooling(im, ftrPTR, *prPTR);
    else if (strcmp(ground, "bg") == 0)
      BgMaxPooling(im, ftrPTR, *prPTR);
    else
      mexErrMsgTxt("fg or bg index is wrong!\n");
    ftrPTR += param.siftCodebookSize;
  }
}



float ComputeInfoGain(float *leftDist, float *rightDist)
{
  float leftNum = leftDist[0] + leftDist[1];
  float rightNum = rightDist[0] + rightDist[1];
  float totalNum = leftNum + rightNum;
  float ratio;

  // entropy on the left side
  float leftEntropy = 0.0f;
  if (leftDist[0] != 0)
  {
    ratio = leftDist[0] / leftNum;
    leftEntropy -= ratio * log2(ratio);
  }
  if (leftDist[1] != 0)
  {
    ratio = leftDist[1] / leftNum;
    leftEntropy -= ratio * log2(ratio);
  }

  // entropy on the right side
  float rightEntropy = 0.0f;
  if (rightDist[0] != 0)
  {
    ratio = rightDist[0] / rightNum;
    rightEntropy -= ratio * log2(ratio);
  }
  if (rightDist[1] != 0)
  {
    ratio = rightDist[1] / rightNum;
    rightEntropy -= ratio * log2(ratio);
  }

  return (-leftEntropy * leftNum - rightEntropy * rightNum) / totalNum;
}



float EvalOnTrain(float *weight, struct problem prob)
{
  float leftDist[2];
  memset(leftDist, 0, sizeof(float) * 2);
  float rightDist[2];
  memset(rightDist, 0, sizeof(float) * 2);

  int predict_label;
  for (int i = 0; i < prob.l; i++)
  {
    struct feature_node *nodePTR = prob.x[i];
    float score = 0;
    while (nodePTR->index != -1)
    {
      score += nodePTR->value * weight[nodePTR->index - 1];
      nodePTR++;
    }
    predict_label = (score > 0) ? 0 : 1;

    // assign to the left or right based on the current data
    if (predict_label == 0)
      leftDist[prob.y[i]] += 1;
    else
      rightDist[prob.y[i]] += 1;
  }

  return ComputeInfoGain(leftDist, rightDist);
}



void EvalOnTrain(float *weight, struct problem prob, float *leftDist, float *rightDist, 
    vector<int> trainID, vector<int> &leftTrainID, vector<int> &rightTrainID)
{
  leftTrainID.clear();
  rightTrainID.clear();

  for (int i = 0; i < prob.l; i++)
  {
    struct feature_node *nodePTR = prob.x[i];
    float score = 0;
    while (nodePTR->index != -1)
    {
      score += nodePTR->value * weight[nodePTR->index - 1];
      nodePTR++;
    }

    if (score > 0)  // predict_label = 0;
    {
      leftDist[prob.y[i]] += 1;
      leftTrainID.push_back(trainID[i]);
    }
    else            // predict_label = 1;
    {
      rightDist[prob.y[i]] += 1;
      rightTrainID.push_back(trainID[i]);
    }
  }
}



void EvalOnVal(float *ftrWeight, int ftrDim, vector<SINGLEIM> imVec, vector<PMREGION> pmRegions, 
    PARAMETER param, float *leftDist, float *rightDist, vector<int> valID, 
    vector<int> valClassID, vector<int> &leftValID, vector<int> &rightValID)
{
  leftValID.clear();
  rightValID.clear();
  int valNum = valID.size();
  int fgFtrDim = pmRegions.size() * param.siftCodebookSize;
  float *feature = (float*)malloc(sizeof(float) * ftrDim);

  for (int i = 0; i < valNum; i++)
  {
    MaxPooling(imVec[valID[i]], feature, pmRegions, param, "fg");  // only fg needs to be pooled
    memcpy(feature + fgFtrDim, imVec[valID[i]].bgHist, sizeof(float) * imVec[valID[i]].bgFtrDim);
    *(feature + ftrDim - 1) = 0.1f;
    float *featurePTR = feature;
    float *weightPTR = ftrWeight;
    float score = 0.0f;
    for (int j = 0; j < ftrDim; j++)
    {
      if (*featurePTR > 0)
        score += *featurePTR * *weightPTR;
      featurePTR++;
      weightPTR++;
    }

    if (score > 0)  // predict_label = 0;
    {
      if (valClassID[i] != -1)
        leftDist[valClassID[i]] += 1;
      leftValID.push_back(valID[i]);
    }
    else
    {
      if (valClassID[i] != -1)
        rightDist[valClassID[i]] += 1;
      rightValID.push_back(valID[i]);
    }
  }
  free(feature);
}



// Train an SVM classifier for the current node given the current feature
//   and evaluate the obtained classifier using information gain.
float TrainCurrentRegion(float ftrX, float ftrY, float ftrWid, float ftrHgt,
    int &ftrDim, float *ftrWeight, vector<SINGLEIM> imVec, vector<int> trainClassID,
    vector<int> trainID, vector<int> valClassID, vector<int> valID, PARAMETER param, 
    vector<int> &leftTrainID, vector<int> &rightTrainID, vector<int> &leftValID, 
    vector<int> &rightValID, vector<PMREGION> &pmRegions)
{
//clock_t t1, t2;
//t1 = clock();
  struct feature_node *x_space;
  struct parameter svm_param;
  struct problem prob;
  struct model* model_;

  // setup the problem
  pmRegions.clear();
  GetPmRegionConfig(ftrX, ftrY, ftrWid, ftrHgt, pmRegions);
  prob.l = trainID.size();  // number of training data for the current node
  // number of features for each data, note the bg feature dim is added
  int fgFtrDim = pmRegions.size() * param.siftCodebookSize;
  // [ywchao]
  mexPrintf("%d %d\n",prob.l,fgFtrDim + imVec[0].bgFtrDim + 1);
  prob.n = fgFtrDim + imVec[0].bgFtrDim + 1;
  prob.bias = 0.1;
  prob.y = (int*)malloc(sizeof(int) * prob.l);
  prob.x = (struct feature_node**)malloc(sizeof(struct feature_node*) * prob.l);
  x_space = (struct feature_node*)malloc(sizeof(struct feature_node) * prob.l * prob.n);

  // do the max-pooling and get the features for the images
  float *tmpFeature = (float*)malloc(sizeof(float) * prob.n);
  int x_count = 0;
  for (int i = 0; i < prob.l; i++)
  {
    // max pooling to obtain foreground features
    MaxPooling(imVec[trainID[i]], tmpFeature, pmRegions, param, "fg");
    // pad the foreground feature with background information
    memcpy(tmpFeature + fgFtrDim, imVec[trainID[i]].bgHist,
        imVec[trainID[i]].bgFtrDim * sizeof(float));
    *(tmpFeature + prob.n - 1) = 0.1f;  // the bias term
    prob.y[i] = trainClassID[i];
    prob.x[i] = &x_space[x_count];

    float *featurePTR = tmpFeature;
    for (int j = 1; j <= prob.n; j++)
    {
      if (*featurePTR > 0)
      {
        x_space[x_count].index = j;
        x_space[x_count].value = *featurePTR;
        x_count++;
      }
      featurePTR++;
    }
    x_space[x_count].index = -1;
    x_count++;
  }

  // setup the training parameters
  svm_param.solver_type = L2R_L2LOSS_SVC_DUAL;
  svm_param.C = 1;
  if ((svm_param.solver_type == L2R_LR) || (svm_param.solver_type == L2R_L2LOSS_SVC))
    svm_param.eps = 0.2;
  else if ((svm_param.solver_type == L2R_L2LOSS_SVC_DUAL) || (svm_param.solver_type == MCSVM_CS)
      || (svm_param.solver_type == L2R_L1LOSS_SVC_DUAL) || (svm_param.solver_type == L2R_LR_DUAL))
    svm_param.eps = 2.0;
  else if ((svm_param.solver_type == L1R_L2LOSS_SVC) || (svm_param.solver_type == L1R_LR))
    svm_param.eps = 0.2;
  svm_param.nr_weight = 0;
  svm_param.weight_label = NULL;
  svm_param.weight = NULL;
//t2 = clock();
//mexPrintf("    Time before SVM: %f\n", (float)(t2 - t1) / CLOCKS_PER_SEC);

  // train the model
//t1 = clock();
  model_ = train(&prob, &svm_param);
//t2 = clock();
//mexPrintf("    Time for SVM: %f\n", (float)(t2 - t1) / CLOCKS_PER_SEC);

  // copy the model to return values
//t1 = clock();
  ftrDim = prob.n;
  float *ftrWeightPTR = ftrWeight;
  double *modelWeightPTR = model_->w;
  for (int i = 0; i < prob.n; i++)
  {
    *ftrWeightPTR = *modelWeightPTR;
    ftrWeightPTR++;
    modelWeightPTR++;
  }

  float leftDist[2], rightDist[2];
  memset(leftDist, 0, sizeof(float) * 2);
  memset(rightDist, 0, sizeof(float) * 2);
  EvalOnTrain(ftrWeight, prob, leftDist, rightDist, trainID, leftTrainID, rightTrainID);
//  mexPrintf("      Left: %d, %d; Right: %d, %d.    ", (int)(leftDist[0]), 
//      (int)(leftDist[1]), (int)(rightDist[0]), (int)(rightDist[1]));
  EvalOnVal(ftrWeight, ftrDim, imVec, pmRegions, param, leftDist, 
      rightDist, valID, valClassID, leftValID, rightValID);
//  mexPrintf("Left: %d, %d; Right: %d, %d.\n", (int)(leftDist[0]), 
//      (int)(leftDist[1]), (int)(rightDist[0]), (int)(rightDist[1]));
  float infoGain = ComputeInfoGain(leftDist, rightDist);

  // destroy and free the memory
  free_and_destroy_model(&model_);
  free(tmpFeature);
  destroy_param(&svm_param);
  free(prob.y);
  free(prob.x);
  free(x_space);
//t2 = clock();
//mexPrintf("    Time after SVM: %f\n", (float)(t2 - t1) / CLOCKS_PER_SEC);

  return infoGain;
}

