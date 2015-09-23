function parsave(outFName, imageInfo, integralData)
try
  save(outFName,  'imageInfo', 'integralData');
catch
  pause(1);
  if(exist(outFName, 'file'))
    unix(['rm ' outFName]);
    %unix(['rm "' outFName '"']);
  end
  parsave(outFName, imageInfo, integralData);
end
end

%{
function parsave(outFName, data, x, y, patchSizes, hgt, wid)
save(outFName,  'data', 'x', 'y', 'patchSizes', 'hgt', 'wid');
end
%}