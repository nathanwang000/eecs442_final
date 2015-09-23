for f in *; do
sed -i 's/hico_20150920/hico_20150920/g' $f;
sed -i 's/anno_iccv.mat/anno_iccv.mat/g' $f;
sed -i 's/length(list_action)/length(list_action)/g' $f;
done
