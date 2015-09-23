import os
import math

# config
numClasses = 600
nCpu = 100
nCpuPerScript = 10
name = "CMFbg" # create mat file bg

# need name, index, start, end
script = '''\
function %s%d()
    if 1
        global sched
        sched= findResource('scheduler', 'type', 'mpiexec')
        set(sched, 'MpiexecFileName', '/home/software/rhel6/mpiexec/bin/mpiexec')
        set(sched, 'EnvironmentSetMethod', 'setenv') %%the syntax for matlabpool must use the (sched, N) format
        matlabpool(sched, 10);
    end
    addpath '/scratch/jiadeng_fluxg/shared/hico_20150920/'
    load anno_iccv.mat
    for i=%d:%d
        action = list_action(i);
        
        [config, config_fg, ...
        trainingpath, savefile, hi, name, testpath, ...
        trainingpath_fg, savefile_fg, hi_fg, name_fg, testpath_fg, ...
        trainingfilepath, trainingfileflippedpath, ...
        trainingfilepath_fg, trainingfileflippedpath_fg, ...
        trainingfilegt, ...
        testfilepath, testfileflippedpath, ...
        testfilepath_fg, testfileflippedpath_fg, ...
        testfilegt] = smallConfig(action);

        %% load input .mat file
        data = load(savefile);
        %% Compile LLC histograms into a single mat file for use with algorithm
        tic
        createMatFilesBg(data, config);
        fprintf('combining LLC: ');
        toc
    end
    if(matlabpool('size')>0)
        matlabpool close;
    end
end
'''

# need name, index, name, index
pbs = '''\
#!/bin/bash
#PBS -N %s%d
#PBS -M jiaxuan@umich.edu
#PBS -m abe
#PBS -V

#PBS -A jiadeng_flux
#PBS -l qos=flux
#PBS -q flux
#PBS -l nodes=10
#PBS -l mem=40g
#PBS -l gres=matlab:1%%matlab_distrib_comp_engine:10
#PBS -l walltime=3:00:00

####  End PBS preamble

#  Include the next three lines always
if [ "x${PBS_NODEFILE}" != "x" ] ; then
   cat $PBS_NODEFILE   # contains a list of the CPUs you were using
fi

#  Put your job commands after this line
module load matlab
matlab -nodisplay -nodesktop -r "run('eecs442final_project/final_project/%s%d.m')"
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
        end = min(numClasses, i+nClassPerScript-1)
        genFiles(index, start, end, name)
        index = index + 1

