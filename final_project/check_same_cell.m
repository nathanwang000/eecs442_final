function [isTrue] = check_same_cell(c1, c2)
    isTrue = 0;
    if length(c1)~=length(c2) 
        return;
    end
    for i=1:length(c1)
        if ~strcmp(c1(i), c2(i))
            return;
        end
    end
    isTrue = 1;
end