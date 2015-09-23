#ifndef _TREEACCESSORY_H_
#define _TREEACCESSORY_H_

#include <fstream>
#include <vector>
#include "parameters.h"
#include "decisiontree.h"
using namespace std;

void OutputTree(TREENODE *tree, char *filename);
void InputTree(TREENODE *tree, TREENODE *treeMemPTR, char *filename, char *action);

void ResetTreeMem(TREENODE *nodes, int nodeNum);
void InitTreeMem(TREENODE *nodes, int nodeNum);
void ReleaseTreeMem(TREENODE *tree);
void GetFilename(char *filename, char *action);
int GetTreeNum(char *action);
void ReadTrees(vector<TREENODE*> &trees, TREENODE *treeMemory, int treeNum, PARAMETER param, char *action);

#endif
