#for((j=1;j<=41;j++)) do 
for j in 28 33 36 39 41 
do
fsl_sub -l ./log/ matlab -nodesktop -nosplash -r "classify_genotype_searchlight_para([1:5000]+5000*(${j}-1),$j);quit;"

done

#fsl_sub -l ./log/ matlab -nodesktop -nosplash -r "classify_genotype_searchlight_para([205001:205283],42);quit;"



