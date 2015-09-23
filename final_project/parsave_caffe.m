function parsave_caffe(outFName, Xrange, Yrange, x, y, patchSizes, hgt, wid)
try
  save(outFName, 'Xrange', 'Yrange', 'x', 'y', 'patchSizes', 'hgt', 'wid');
catch
  pause(1);
  if(exist(outFName, 'file'))
    unix(['rm ' outFName]);
    %unix(['rm "' outFName '"']);
  end
  parsave_caffe(outFName, Xrange, Yrange, x, y, patchSizes, hgt, wid);
end
end

%{
  function parsave_caffe(outFName, Xrange, Yrange,  x, y, patchSizes, hgt, wid)
    save(outFName,  'Xrange', 'Yrange', 'x', 'y', 'patchSizes', 'hgt', 'wid');
end
%}
