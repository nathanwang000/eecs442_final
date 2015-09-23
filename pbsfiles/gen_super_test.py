''' 
This is a helper script to generate appropriate pbs files
'''
template = '''
#!/bin/bash
#PBS -N outputbinary_test%d_%d
#PBS -M jiaxuan@umich.edu
#PBS -m abe
#PBS -V

#PBS -A jiadeng_flux
#PBS -l qos=flux
#PBS -q flux
#PBS -l nodes=1
#PBS -l mem=10g
#PBS -l walltime=10:00:00

####  End PBS preamble

#  Include the next three lines always
if [ "x${PBS_NODEFILE}" != "x" ] ; then
   cat $PBS_NODEFILE   # contains a list of the CPUs you were using
fi

#  Put your job commands after this line
module load matlab
matlab -nodisplay -nodesktop -r "cd eecs442final_project/final_project/;super_massive_outputBinaryFeature_test(%d:%d)"
echo "process complete"
'''

import subprocess
import os

if __name__ == '__main__':
    # action = range(1,601)
    # start = action[::12] # use 12 instead of 6 b/c test output don't need to output flipped image so the amount of work is half
    # end = map(lambda x: x+11, start)
    start = [489]
    end = start

    for s,e in zip(start, end):
        filename = 'outputbinary_test_%d_%d.pbs' % (s,e) 
        with open(filename, 'wb') as f:
            f.write(template % (s,e,s,e))
        os.system("qsub %s" % filename)
