import os
import math

# config
numClasses = 600
nCpu = 180
nCpuPerScript = 10
name = "OBte" # outputBinary for test

# need name, index, start, end
script = '''\
'''

# need name, index, name, index
pbs = '''\
#!/bin/bash
#PBS -N %s
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
matlab -nodisplay -nodesktop -r "cd eecs442final_project/final_project/;super_massive_outputBinaryFeature_test(489:489)"
echo "process complete"
'''
def genFiles(index, start, end, name):
    # generate the pbs and script file
    curDir = os.path.dirname(os.path.realpath(__file__))
    scriptFile = os.path.join(curDir, "../final_project/%s%d.m" % (name,index))
    pbsFile = os.path.join(curDir, "../pbsfiles/%s%d.pbs" % (name,index))
    with open(scriptFile,'w') as f:
        f.write(script % (name, index, start, end))
    with open(pbsFile,'w') as f:
        f.write(pbs % (name, index, name, index))
    # submit the file
    print("cd %s; qsub %s%d.pbs" % (os.path.dirname(pbsFile), name, index))
    os.system("cd %s; qsub %s%d.pbs" % (os.path.dirname(pbsFile), name, index))

if __name__ == '__main__':
    # start extracting sift
    index = 1
    nScripts = math.ceil(nCpu / nCpuPerScript)
    nClassPerScript = int(math.ceil(numClasses / nScripts))
    for i in range(1,numClasses+1,nClassPerScript):
        start = i
        end = min(nCpu, i+nClassPerScript-1)
        genFiles(index, start, end, name)
        index = index + 1
