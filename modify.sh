for f in *; do
sed -i 's/hico_20150912/hico_20150920/g' $f;
sed -i 's/anno_iccv.mat/anno_iccv.mat/g' $f;
sed -i 's/length(action)/length(list_action)/g' $f;
done
