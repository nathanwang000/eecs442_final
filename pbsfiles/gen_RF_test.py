template = '''
#!/bin/bash
#PBS -N test_RF_%d_%d
#PBS -M jiaxuan@umich.edu
#PBS -m abe
#PBS -V

#PBS -A jiadeng_flux
#PBS -l qos=flux
#PBS -q flux
#PBS -l nodes=1
#PBS -l mem=10g
#PBS -l walltime=12:00:00
#PBS -l gres=matlab:1%%matlab_distrib_comp_engine:12

####  End PBS preamble

#  Include the next three lines always
if [ "x${PBS_NODEFILE}" != "x" ] ; then
   cat $PBS_NODEFILE   # contains a list of the CPUs you were using
fi

#  Put your job commands after this line
module load matlab
matlab -nodisplay -nodesktop -r "cd eecs442final_project/final_project/;massive_test_RF(%d:%d)"
echo "process completed"
'''

import subprocess
import os

if __name__ == '__main__':
    action = range(1,601)
    start = action[::12] # use 12 instead of 6 b/c test output don't need to output flipped image so the amount of work is half
    end = map(lambda x: x+11, start)

    # start = [489]
    # end = [489]

    for s,e in zip(start, end):
        filename = 'test_RF_%d_%d.pbs' % (s,e) 
        with open(filename, 'wb') as f:
            f.write(template % (s,e,s,e))
        os.system("qsub %s" % filename)
