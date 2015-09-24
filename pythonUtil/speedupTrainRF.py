import os
import math

# config
num = 600
nCpu = 300
nCpuPerScript = 1
name = "RFtr" # trainRF

# need name, index, start, end
script = '''\
function %s%d()
  tic
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
    
        Datafilename = sprintf('/scratch/jiadeng_fluxg/jiaxuan/RF_related/trainval_0_%%s_%%s.txt', action.vname, action.nname);
        DatafilenameFlipped = sprintf('/scratch/jiadeng_fluxg/jiaxuan/RF_related/trainval_0_%%s_%%s_flipped.txt', action.vname, action.nname);
        
        fprintf('train RF on %%s %%s, working on %%d/%%d\\n', action.vname, action.nname, i, length(list_action));
        %% deleting existing trees
        system(sprintf('rm /scratch/jiadeng_fluxg/jiaxuan/trees/%%s_%%s/*', action.vname, action.nname));
        %% make the directory if not exist
        system(sprintf('mkdir -p /scratch/jiadeng_fluxg/jiaxuan/trees/%%s_%%s/', action.vname, action.nname));

                
        TreeNum = 30;
        dttrain(TreeNum, Datafilename, DatafilenameFlipped, [action.vname, '_' ,action.nname]);

    end

toc
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
#PBS -l walltime=24:00:00

####  End PBS preamble
# previous node=12, mem=90
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
    os.system("cd %s; qsub %s%d.pbs" % (os.path.dirname(pbsFile), name, index))

if __name__ == '__main__':
    index = 1
    step = int(math.ceil(float(num)/nCpu))
    for i in range(1,num+1,step):
        start = i
        end = min(num, i+step-1)
        genFiles(index, start, end, name)
        index = index + 1

