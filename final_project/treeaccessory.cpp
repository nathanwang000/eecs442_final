#include "unistd.h"
#include "treeaccessory.h"
#include "mex.h"
#include <math.h>


// iteratively outputting the tree nodes
void OutputTreeNode(TREENODE *node, char *filename)
{
  ofstream fout(filename, ios::app);

  fout << node->nodeID << " " << node->depth << " " << node->classNum << endl;
  fout << node->ftrX << " " << node->ftrY << " " << node->ftrWid << " " << node->ftrHgt << endl;
  fout << node->pmRegions.size() << endl;
  for (int i = 0; i < node->pmRegions.size(); i++)
  {
    fout << node->pmRegions[i].x << " " << node->pmRegions[i].y << " " 
        << node->pmRegions[i].wid << " " << node->pmRegions[i].hgt << "  ";
  }
  if (node->pmRegions.size() != 0)
    fout << endl;
  fout << node->ftrDim << endl;
  float *weightPTR = node->ftrWeight;
  for (int i = 0; i < node->ftrDim; i++)
  {
    fout << *weightPTR << " ";
    weightPTR++;
    if (i % 50 == 49)
      fout << endl;
  }
  if ((node->ftrDim - 1) % 50 != 49)
    fout << endl;
  fout << node->lchildID << " " << node->rchildID << endl;
  if (node->labelDist != NULL)
  {
    float *distPTR = node->labelDist;
    for (int i = 0; i < node->classNum; i++)
    {
      fout << *distPTR << " ";
      distPTR++;
    }
  }
  fout << endl << endl << endl;

  fout.close();
  if (node->lchild != NULL)
    OutputTreeNode(node->lchild, filename);
  if (node->rchild != NULL)
    OutputTreeNode(node->rchild, filename);
}



// output the tree to the corresponding file
void OutputTree(TREENODE *tree, char *filename)
{
  ofstream fout(filename);
  if (fout.fail())
    mexErrMsgTxt("Failed to create the file for outputing trees");
  fout.close();

  OutputTreeNode(tree, filename);
}



void InitTreeMem(TREENODE *nodes, int nodeNum)
{
  TREENODE *nodePTR = nodes;
  for (int i = 0; i < nodeNum; i++)
  {
    nodePTR->nodeID = -1;
    nodePTR->pmRegions.clear();
    nodePTR->ftrDim = 0;
    nodePTR->ftrWeight = NULL;
    nodePTR->labelDist = NULL;
    nodePTR->lchild = NULL;
    nodePTR->rchild = NULL;
    nodePTR->lchildID = -1;
    nodePTR->rchildID = -1;
    nodePTR++;
  }
}



// initialize the memory and the other variables of all the nodes in a tree
void ResetTreeMem(TREENODE *nodes, int nodeNum)
{
  TREENODE *nodePTR = nodes;
  for (int i = 0; i < nodeNum; i++)
  {
    nodePTR->nodeID = -1;
    nodePTR->pmRegions.clear();
    nodePTR->ftrDim = 0;
    if (nodePTR->ftrWeight != NULL)
    {
      free(nodePTR->ftrWeight);
      nodePTR->ftrWeight = NULL;
    }
    if (nodePTR->labelDist != NULL)
    {
      free(nodePTR->labelDist);
      nodePTR->labelDist = NULL;
    }
    nodePTR->lchild = NULL;
    nodePTR->rchild = NULL;
    nodePTR->lchildID = -1;
    nodePTR->rchildID = -1;
    nodePTR++;
  }
}



void ReleaseTreeMem(TREENODE *tree)
{
  tree->pmRegions.clear();
  if (tree->ftrWeight != NULL)
  {
    free(tree->ftrWeight);
    tree->ftrWeight = NULL;
  }
  if (tree->labelDist != NULL)
  {
    free(tree->labelDist);
    tree->labelDist = NULL;
  }

  tree->lchild = NULL;
  tree->rchild = NULL;
}



void GetFilename(char *filename, char *action)
{
  char tmpName[1024];
  for (int i = 0; i < 1000; i++)
  {
    sprintf(tmpName, "/scratch/jiadeng_fluxg/jiaxuan/trees/%s/tree_%d%d%d.txt", action, i / 100, (i % 100) / 10, i % 10);
    if (access(tmpName, F_OK) != -1)  // file exists
      continue;
    else                              // file does not exist
    {
      sprintf(filename, "%s", tmpName);
      ofstream fout(filename);
      if (fout.fail())
        mexErrMsgTxt("Failed to create the file for outputing trees");
      fout.close();
      break;
    }
  }
}



// check the filenames to see the number of trees
int GetTreeNum(char *action)
{
  int treeNum = 0;
  char filename[1024];
  sprintf(filename, "/scratch/jiadeng_fluxg/jiaxuan/trees/%s/tree_%d%d%d.txt", action, treeNum / 100, (treeNum % 100) / 10, treeNum % 10);
  while (access(filename, F_OK) != -1)
  {
    treeNum++;
    sprintf(filename, "/scratch/jiadeng_fluxg/jiaxuan/trees/%s/tree_%d%d%d.txt", action, treeNum / 100, (treeNum % 100) / 10, treeNum % 10);
  }
  mexPrintf("The tree num from GetTreeNum is %d\n", treeNum);
  return treeNum;
}



// read the information of a tree from a file
bool InputTree(TREENODE *treeNodes, char *filename)
{
  ifstream fin(filename);
  if (fin.fail())  // the file cannot be succesfully opened
    return false;

  TREENODE *nodePTR = treeNodes;
  int prevId = 0;
  int prevDepth = 0;
  int prevClassNum = 0;
  while (!fin.eof())
  { 
     
    try
    {
      fin >> nodePTR->nodeID >> nodePTR->depth >> nodePTR->classNum;
      mexPrintf("read in tree id:%d depth:%d Num of classes:%d\n", nodePTR->nodeID, nodePTR->depth, nodePTR->classNum);
      if (prevId == -1 && nodePTR->nodeID == -1)
          return false;
      else{
          prevId = nodePTR->nodeID;
          prevDepth = nodePTR->depth;
          prevClassNum = nodePTR->classNum;
      }
          
      fin >> nodePTR->ftrX >> nodePTR->ftrY >> nodePTR->ftrWid >> nodePTR->ftrHgt;
//      mexPrintf("%f %f %f %f\n", nodePTR->ftrX, nodePTR->ftrY, nodePTR->ftrWid, nodePTR->ftrHgt);
      int regionSize;
      fin >> regionSize;
//      mexPrintf("%d  ", regionSize);
      for (int i = 0; i < regionSize; i++)
      {
        PMREGION pr;
        fin >> pr.x >> pr.y >> pr.wid >> pr.hgt;
//        mexPrintf("%f %f %f %f  ", pr.x, pr.y, pr.wid, pr.hgt);
        nodePTR->pmRegions.push_back(pr);
      }
//      mexPrintf("\n");
      fin >> nodePTR->ftrDim;
//      mexPrintf("%d  ", nodePTR->ftrDim);
      if (nodePTR->ftrDim != 0)
      {
        nodePTR->ftrWeight = (float*)malloc(sizeof(float) * nodePTR->ftrDim);
        float *weightPTR = nodePTR->ftrWeight;
        for (int i = 0; i < nodePTR->ftrDim; i++)
        {
          fin >> *weightPTR;
          weightPTR++;
        }
      }
//      mexPrintf("%f %f\n", nodePTR->ftrWeight[0], nodePTR->ftrWeight[nodePTR->ftrDim - 1]);
      fin >> nodePTR->lchildID >> nodePTR->rchildID;
//      mexPrintf("%d %d\n", nodePTR->lchildID, nodePTR->rchildID);
      if ((nodePTR->lchildID == -1) && (nodePTR->rchildID == -1))
      {
        nodePTR->labelDist = (float*)malloc(sizeof(float) * nodePTR->classNum);
        float *distPTR = nodePTR->labelDist;
        for (int i = 0; i < nodePTR->classNum; i++)
        {
          fin >> *distPTR;
          distPTR++;
        }
      }
    }
    catch (int e)  // error occurs when reading the file
    {
      return false;
    }

    nodePTR++;
  }

  fin.close();
  
  // for those nodes whose children are not -1, connect them to the child nodes
  nodePTR = treeNodes;
  while (nodePTR->nodeID != -1)
  {
    // note that lchildID is -1 implies that rchildID is -1 as well
    if ((nodePTR->lchildID == -1) && (nodePTR->rchildID == -1))
    {
      nodePTR++;
      continue;
    }

    TREENODE *nodePTR2 = treeNodes;
    while (nodePTR2->nodeID != -1)
    {
      if (nodePTR2->nodeID == nodePTR->lchildID)
        nodePTR->lchild = nodePTR2;
      if (nodePTR2->nodeID == nodePTR->rchildID)
        nodePTR->rchild = nodePTR2;
      nodePTR2++;
    }

    nodePTR++;
  }

  return true;
}



// check if the tree is valid
// a valid tree means one node is either a leaf node, or its descdent can be a leaf node
bool CheckValidTree(TREENODE *treeNodes, int maxNodeNum)
{
  // if the first node does not have values, then return false
  if (treeNodes->nodeID == -1)
    return false;

  // we always descend to the right child of each node
  TREENODE *nodePTR = treeNodes;
  while (nodePTR->nodeID != -1)
  {
    if ((nodePTR->lchild == NULL) && (nodePTR->rchild == NULL))
    {
      // this node itself is a leaf node
      nodePTR++;
      continue;
    }

    bool flag = false;
    TREENODE *tmpNode = nodePTR;
    while (1)
    {
      if (tmpNode->nodeID == -1)
        break;

      if ((tmpNode->lchild == NULL) && (tmpNode->rchild == NULL))
      {
        // reach a leaf node
        flag = true;
        break;
      }
      else
        tmpNode = tmpNode->rchild;
    }

    if (!flag)
      return false;
    nodePTR++;
  }

  return true;
}



bool InputTree(TREENODE *treeNodes, int treeID, int maxNodeNum, char *action)
{
  // check if the tree filename exists
  char filename[1024];
  sprintf(filename, "/scratch/jiadeng_fluxg/jiaxuan/trees/%s/tree_%d%d%d.txt", action, treeID / 100, (treeID % 100) / 10, treeID % 10);
  if (access(filename, F_OK) == -1)
  {
    mexPrintf("Failed openning file for tree %d.\n", treeID);
    return false;  // the file does not exist
  }

  // read the tree to the temporary memory
  ResetTreeMem(treeNodes, maxNodeNum);
  if (!InputTree(treeNodes, filename))
  {
    mexPrintf("Cannot finish reading the tree %d.\n", treeID);
    return false;
  }
  if (!CheckValidTree(treeNodes, maxNodeNum))
  {
    mexPrintf("The tree cannot pass the check %d.\n", treeID);
    return false;
  }

  return true;
}



// read trees from the memory
void ReadTrees(vector<TREENODE*> &trees, TREENODE *treeMemory, int treeNum, PARAMETER param, char *action)
{
  int maxNodeNum = int(pow(2, param.maxTreeDepth + 1));
  TREENODE *treeMemPTR = treeMemory;

  for (int i = 0; i < treeNum; i++)
  {
    if (InputTree(treeMemPTR, i, maxNodeNum, action))  // the tree to be read exists and is a valid tree
    {
      trees.push_back(treeMemPTR);
      treeMemPTR += maxNodeNum;
    }
  }
}


