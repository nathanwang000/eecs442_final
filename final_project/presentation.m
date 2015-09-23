function presentation()
    % this is basically for presentation on Tuesday
    load '/scratch/jiadeng_fluxg/shared/hico_20150920/anno_iccv.mat'
    global anno_train; global anno_test; global list_train; global list_test; global list_action;
    % ftrX, ftrY, width, height
    features = load_pickle('/scratch/jiadeng_fluxg/jiaxuan/presentation_features.pkl');
%    for target=[1:600]
%        action = list_action(target);
%        present_helper(target, getfield(features, [action.vname '_' action.nname]));
%        fprintf('%d/600 done\n', target);
%    end
target = 21;
action = list_action(target);
disp([action.vname '_' action.nname]);
present_helper(target, getfield(features, [action.vname '_' action.nname]));
end

function present_helper(target, positions)
          
    %figure;
    global anno_train; global anno_test; global list_train; global list_test; global list_action;
    action = list_action(target);
    
    % get the all the images of the target class
    imTrain_pos = list_train(anno_train(target,:) == 1); 
    %imTrain_neg = list_train(anno_train(target,:) ~= 0 & anno_train(target,:) ~= 1);
    %imTest_pos = list_test(anno_test(target,:) ~= 0);
    %imTest_neg = list_test(anno_test(target,:) ~= 0 & anno_test(target,:) ~= 1);
    
    % show the target class
    % im = imread(['/scratch/jiadeng_fluxg/shared/hico_20150920/images/' imTrain_pos{randi([1,length(imTrain_pos)])}]);
    im = imread(['/scratch/jiadeng_fluxg/shared/hico_20150920/images/' imTrain_pos{1}]);
    [h,w, ~] = size(im);
    % pad border and caption
    %pad_size = floor(min(w,h)*0.03);
    %im = padarray(im, [pad_size, pad_size]);
    imshow(im);%, 'axis', 'tight');
    title([action.vname ' ' action.nname]);

    hold on;
    lw = min(h, w) * 0.01;
    %set(gca,'position',[0 0 1 1],'units','normalized')
    
    colors = {'r', 'b', 'g', 'k', 'y', 'c', 'm', 'w'};
    for i=1:size(positions,1)
        pos = positions(i,:);
        pos(1) = pos(1) * w;% + pad_size;
        pos(2) = pos(2) * h;% + pad_size;
        pos(3) = pos(3) * w;
        pos(4) = pos(4) * h;
        rectangle('Position', pos, 'EdgeColor', colors{i}, 'LineWidth', lw);    
    end
        
    saveas(gcf, sprintf('/scratch/jiadeng_fluxg/jiaxuan/presentation/images/%s_%s.jpg', action.vname, action.nname));
    close all;

end

function a=load_pickle(filename)
    if ~exist(filename,'file')
        error('%s is not a file',filename);
    end
    outname = [tempname() '.mat'];
    pyscript = ['import cPickle as pickle;import sys;import scipy.io;file=open("' filename '","r");dat=pickle.load(file);file.close();scipy.io.savemat("' outname '",dat)'];
    system(['python -c ''' pyscript '''']);
    a = load(outname);
end