''' 
This is a helper script to generate appropriate pbs files
'''
template = '''
#!/bin/bash
#PBS -N outputTrain_%d_%d
#PBS -M jiaxuan@umich.edu
#PBS -m abe
#PBS -V

#PBS -A jiadeng_flux
#PBS -l qos=flux
#PBS -q flux
#PBS -l nodes=1
#PBS -l mem=5g
#PBS -l walltime=10:00:00

####  End PBS preamble

#  Include the next three lines always
if [ "x${PBS_NODEFILE}" != "x" ] ; then
   cat $PBS_NODEFILE   # contains a list of the CPUs you were using
fi

#  Put your job commands after this line
module load matlab
matlab -nodisplay -nodesktop -r "cd eecs442final_project/final_project/;super_massive_generate_idsfile(%d:%d)"
echo "process complete"
'''
# have done 25,30
import subprocess
import os

def check_files():
    action = range(1,601)
    start = action[::6]
    end = map(lambda x: x+5, start)
    
    zerofiles = set()
    with open('zero_size.txt') as f:
        for l in f:
            l = l[2:l.find('.e')]
            zerofiles.add(l)

    for s,e in zip(start, end):
        filename = 'outputTrain_%d_%d' % (s,e)
        if filename not in zerofiles:
            print "%s is probabily wrong" % filename
    print "done"
    

if __name__ == '__main__':
    # action = range(1,601)
    # start = action[::6]
    # end = map(lambda x: x+5, start)
    start = [489]
    end = start
    
    for s,e in zip(start, end):
        filename = 'outputBinaryTrain_%d_%d.pbs' % (s,e) 
        with open(filename, 'wb') as f:
            f.write(template % (s,e,s,e))
        os.system("qsub %s" % filename)
