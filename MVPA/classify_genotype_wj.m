% classify genotype based on brain data
% 2014-11-17

addpath('/expdata/wangjing/JOL/toolbox');
addpath('/expdata/gxue/scripts/NIFTI');
addpath('/expdata/wangjing/scripts/liblinear-1.92/liblinear-1.92/matlab');
addpath('/expdata/wangjing/scripts/libsvm-3.12/matlab');
clear
clc
basedir ='/expdata/chunhui/zang/vbm/vbm_cw/stats/';
maskname='/expdata/chunhui/zang/vbm/vbm_cw/stats/GM_mask.nii';
para=1000;%.^[-6:6];
tic;
%%%%%%%%%%%%%%
load BDNFCOMT10group;
genotype=data(:,6);
group=data(:,9);

idx=[ones(281,1)];
filename=sprintf('%sGM_mod_merg_s3.nii',basedir);
x=nii2x(filename,maskname,idx);

predic10=[]; actural10=[];
for gidx=1:10 % 10 groups leave one out
    idx_test=find(group==gidx);
    idx_train=find(group~=gidx);
    label_test=genotype(idx_test);
    label_train=genotype(idx_train);%[ones(1,30) ones(1,30)*2 ones(1,30)*3 ]';
    % %    label_predict=zeros(size(label_test))



    x_test=x(idx_test,:);
    x_train=x(idx_train,:);

    x_train=sparse(x_train);
    x_test=sparse(x_test);

    % zscore or not
    [x_train, x_test]=norm_zscore(x_train,x_test);

    for ipara=1:length(para)
        options=sprintf('-s 0 -c %d -q', para(ipara));
        model=train(label_train,x_train,options);
        [label_predict,accuracy,decision_values]=predict(label_test,x_test,model,'-b 1 -q');

        all_results(gidx).accuracy=accuracy;
        all_results(gidx).predict=label_predict;
        all_results(gidx).decision=decision_values;
    end
    
    predic10=[predic10; label_predict];
    actural10=[actural10; label_test];
    
end
% accuracy=label2acc(genotype,predic10);
accuracy=length(find((predic10-actural10)==0))/length(actural10)
%%%%%%%%%%%%%%
time=toc/3600;