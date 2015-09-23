function INT44()
% read from /home/jiaxuan/eecs442final_project/fullDataset.txt
fid = fopen('/home/jiaxuan/eecs442final_project/fullDataset.txt');
from = 6881; to = 7040;
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
