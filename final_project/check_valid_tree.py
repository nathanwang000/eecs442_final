''' 
valid tree should be of this form:
0 0 2
'''
import os
import os.path

if __name__ == '__main__':
    root = "/scratch/jiadeng_fluxg/jiaxuan/trees/"
    folders = filter(os.path.isdir, os.listdir(root))
    print folders
    # for folder in folders:
        
    #     for fn in files:
    #         with open(fn, 'r') as f:
    #             if f.readlines()[0] != "0 0 2\n":
    #                 print "%s might be corrupted" % fn
