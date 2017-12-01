cd results
maskname='/expdata/chunhui/zang/vbm/vbm_cw/stats/GM_mask.nii';


temp=[];
for i=1:42
    eval(sprintf('load classify_genotype_%d.mat',i));
    temp=[temp voxelaccuracy];
end
x2nii(temp,maskname,'accuracy_BDNFCOMT.nii');