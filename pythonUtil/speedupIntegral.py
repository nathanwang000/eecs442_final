import os
import math

# config
num = 47774
nCpu = 300
nCpuPerScript = 1
name = "INT" # create mat file bg

# need name, index, start, end
script = '''\
function %s%d()
%% read from /home/jiaxuan/eecs442final_project/fullDataset.txt
fid = fopen('/home/jiaxuan/eecs442final_project/fullDataset.txt');
from = %d; to = %d;
index = 1;
name = fgetl(fid);
%% preread
while (index < from)
    name = fgetl(fid);
    index = index+1;
end
%% actual work
while (from <= to && ischar(name))
    smallIntegral(name);
    name = fgetl(fid);
    from = from+1;
end
end
'''

# need name, index, name, index
pbs = '''\
#!/bin/bash
#PBS -N %s%d
#PBS -M jiaxuan@umich.edu
#PBS -m a
#PBS -V

#PBS -A jiadeng_flux
#PBS -l qos=flux
#PBS -q flux
#PBS -l nodes=1
#PBS -l mem=4g
#PBS -l walltime=10:00:00

####  End PBS preamble

#  Include the next three lines always
if [ "x${PBS_NODEFILE}" != "x" ] ; then
   cat $PBS_NODEFILE   # contains a list of the CPUs you were using
fi

#  Put your job commands after this line
module load matlab
matlab -nodisplay -nodesktop -r "run('eecs442final_project/final_project/%s%d.m')"
echo "process completed"
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
    index = 1
    step = int(math.ceil(float(num)/nCpu))
    for i in range(1,num+1,step):
        start = i
        end = min(num, i+step-1)
        genFiles(index, start, end, name)
        index = index + 1
