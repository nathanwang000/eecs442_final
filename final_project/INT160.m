function INT160()
% read from /home/jiaxuan/eecs442final_project/fullDataset.txt
fid = fopen('/home/jiaxuan/eecs442final_project/fullDataset.txt');
from = 25441; to = 25600;
index = 1;
name = fgetl(fid);
% preread
while (index < from)
    name = fgetl(fid);
    index = index+1;
end
% actual work
while (from <= to && ischar(name))
    smallIntegral(name);
    name = fgetl(fid);
    from = from+1;
end
end
