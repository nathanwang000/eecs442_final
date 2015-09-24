import os
import math

notDoList = [105,107,125,273,289,292]

# config
num = 600
nCpu = 300
nCpuPerScript = 1
name = "RFte" # testRF

# need name, index, start, end
script = '''\
function %s%d()    
    addpath '/scratch/jiadeng_fluxg/shared/hico_20150920/'
    load anno_iccv.mat
    for i=%d:%d
        action = list_action(i);
        fprintf('test_RF on %%s %%s, working on %%d/%%d\\n', action.vname, action.nname, i, length(list_action));
        %% renaming and deleting empty trees
        %% system(sprintf('bash /scratch/jiadeng_fluxg/jiaxuan/trees/del_empty_trees_%%s_%%s.sh', action.vname, action.nname));
        evaluation(action);
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
#PBS -l mem=8g
#PBS -l walltime=3:00:00

####  End PBS preamble

#  Include the next three lines always
if [ "x${PBS_NODEFILE}" != "x" ] ; then
   cat $PBS_NODEFILE   # contains a list of the CPUs you were using
fi

#  Put your job commands after this line
module load matlab
matlab -nodisplay -nodesktop -r "cd eecs442final_project/final_project/;%s%d"
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
    if index not in notDoList:
        os.system("cd %s; qsub %s%d.pbs" % (os.path.dirname(pbsFile), name, index))

if __name__ == '__main__':
    index = 1
    step = int(math.ceil(float(num)/nCpu))
    for i in range(1,num+1,step):
        start = i
        end = min(num, i+step-1)
        genFiles(index, start, end, name)
        index = index + 1

