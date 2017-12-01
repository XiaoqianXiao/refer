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

para=10.^[-6:6];
tic;


%%%%%%%%%%%%%%
    idx_test=[ones(30,1); zeros(251,1)];
    idx_train=[zeros(30,1); ones(90,1); zeros(161,1)];
    label_test=[ones(1,10) ones(1,10)*2 ones(1,10)*3 ]';
    label_train=[ones(1,30) ones(1,30)*2 ones(1,30)*3 ]';
%    label_predict=zeros(size(label_test))
        
    
        filename=sprintf('%sGM_mod_merg_s3.nii',basedir);
        x_test=nii2x(filename,maskname,idx_test);
        x_train=nii2x(filename,maskname,idx_train);
        
        x_train=sparse(x_train);
        x_test=sparse(x_test);
        
        % zscore or not
        [x_train, x_test]=norm_zscore(x_train,x_test);
                
        for ipara=1:length(para)
            options=sprintf('-s 0 -c %0.3f -q', para(ipara));
            model=train(label_train,x_train,options);
            [label_predict,accuracy,decision_values]=predict(label_test,x_test,model,'-b 1 -q');
            
            all_results(ipara).accuracy=accuracy;
            all_results(ipara).predict=label_predict;
            all_results(ipara).decision=decision_values;
        end

%%%%%%%%%%%%%%
time=toc/3600;
save gene_classify_result all_results



return
sub=[1 2 3];
nSub=numel(sub);
%nTR=4;
%accuracy=zeros(nTR,nSub);
% para=10.^[-6:6];
para=10.^3;
tic;
for iSub=1:nSub
    sub_current=sub(iSub);
    fprintf('Subject %d is processing.\n',sub_current);
    load(sprintf('%sTrial_list/Sub%02d_trial_list.mat',basedir, sub_current));
    
%     label_test = all_test(find(all_test(:,4)==1),1);
    label_test = all_test(:,1);
    label_train = all_loc(:,1);
    
    idx_test = find(all_test(:,1)>0);
%     idx_test = find(all_test(:,4)==1);
    idx_train = find(all_loc(:,1)>0);
    
    label_predict=zeros(size(label_test));
        
    for TR = 1:6
        filename=sprintf('%sExtracted_data/Extracted_testing_Sub%02d_TR%d.nii',basedir,sub_current,TR);
        x_test=nii2x(filename,maskname,idx_test);
        
        filename=sprintf('%sExtracted_data/Extracted_localizer_Sub%02d.nii',basedir,sub_current);
        x_train=nii2x(filename,maskname,idx_train);
        
        x_train=sparse(x_train);
        x_test=sparse(x_test);
        
        % zscore or not
        [x_train, x_test]=norm_zscore(x_train,x_test);
                
        for ipara=1:length(para)
            options=sprintf('-s 0 -c %f10.3f -q', para(ipara));
            model=train(label_train,x_train,options);
            [label_predict,accuracy,decision_values]=predict(label_test,x_test,model,'-b 1 -q');
            
            all_results(iSub,TR,ipara).accuracy=accuracy;
            all_results(iSub,TR,ipara).predict=label_predict;
            all_results(iSub,TR,ipara).decision=decision_values;
        end
        filename=sprintf('%sExtracted_data/Extracted_testing_Sub%02d_TR%d.nii',basedir,sub_current,TR);
        x_test=nii2x(filename,maskname,idx_test);
        
        filename=sprintf('%sExtracted_data/Extracted_localizer_Sub%02d.nii',basedir,sub_current);
        x_train=nii2x(filename,maskname,idx_train);
        
        x_train=sparse(x_train);
        x_test=sparse(x_test);
        
        % zscore or not
        [x_train, x_test]=norm_zscore(x_train,x_test);
                
        for ipara=1:length(para)
            options=sprintf('-s 0 -c %f10.3f -q', para(ipara));
            model=train(label_train,x_train,options);
            [label_predict,accuracy,decision_values]=predict(label_test,x_test,model,'-b 1 -q');
            
            all_results(iSub,TR,ipara).accuracy=accuracy;
            all_results(iSub,TR,ipara).predict=label_predict;
            all_results(iSub,TR,ipara).decision=decision_values;
        end
    end
    perct(toc,iSub,nSub);
end
time=toc/3600;
save test_classify_result all_results
% save('test_classify.mat','accuracy','time');