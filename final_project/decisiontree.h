#ifndef DECISIONTREE_H
#define DECISIONTREE_H

#include <vector>
#include <fstream>
#include "feature.h"
#include "parameters.h"
#include "nodeclassifier.h"
using namespace std;

typedef struct _tree_node
{
  int nodeID;  // ID of the current node in the tree
  int depth;  // depth of the current tree node
  int classNum;
  float ftrX, ftrY, ftrWid, ftrHgt;  // defines the image region for the feature in this node
  vector<PMREGION> pmRegions; // spatial pyramid configuration for this tree node
  int ftrDim;  // dimensionality of the features in the current node
  float *ftrWeight;  // feature weights corresponding to the current node
  float *labelDist;  // distribution of samples in different classes in the current node
  struct _tree_node *lchild, *rchild;  // two child nodes of the tree
  int lchildID, rchildID;
} TREENODE;

void InitializeTree(TREENODE *treeNode);
void TrainDecisionTree(TREENODE *treeNode, vector<SINGLEIM> imVec, 
    PARAMETER param, vector<int> trainID, vector<int> valID, int classNum, 
    int &nodeID, TREENODE *treeMemory, int &treeMemID, float *valDist);
void TestDecisionTree(vector<SINGLEIM> imVec, TREENODE *tree, float *result, PARAMETER param, int classNum_test);

#endif
