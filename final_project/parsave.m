function parsave(outFName, data, x, y, patchSizes, hgt, wid)
try
  save(outFName,  'data', 'x', 'y', 'patchSizes', 'hgt', 'wid');
catch
  pause(1);
  if(exist(outFName, 'file'))
    unix(['rm ' outFName]);
    %unix(['rm "' outFName '"']);
  end
  parsave(outFName, data, x, y, patchSizes, hgt, wid);
end
end

%{
function parsave(outFName, data, x, y, patchSizes, hgt, wid)
save(outFName,  'data', 'x', 'y', 'patchSizes', 'hgt', 'wid');
end
%}