% searchlight, cross runs, zsocre, linear kernel libsvm
% 2013-08-05

clear,clc;
addpath('/expdata/wangjing/JOL/toolbox');
addpath('/expdata/gxue/scripts/NIFTI');
addpath('/expdata/wangjing/scripts/liblinear-1.92/liblinear-1.92/matlab');
addpath('/expdata/wangjing/scripts/libsvm-3.12/matlab');


% create a searchlight mask
r=3; % radius
riSlm=[]; % relative index of searchlight mask
for i=-r:r
    for j=-r:r
        for k=-r:r
            if i^2+j^2+k^2<=r^2
                riSlm=[riSlm;[i,j,k]];
            end
        end
    end
end
nPsl=size(riSlm,1); % number of points in a searchlight

% load statistics
sub=[301:321,323:328];
nSub=numel(sub);
nRun=3;

maskname='/expdata/wangjing/JOL/data/mask/gray_mask.nii';
nii=load_untouch_nii(maskname);
img=nii.img;
sz=size(img);
ixMask=find(img);
nSl=sum(img(:));

accuracy=zeros(nSl,nRun,nSub);
tic;
for iSub=1:nSub
    sub_current=sub(iSub);
    fprintf('Subject %d is processing.\n',sub_current);
    load(sprintf('/expdata/wangjing/JOL/7th/trans/task_2/%d.mat',sub_current));
    % label, idx, trans_choice, table
    
    % load data
    filename=sprintf('/expdata/wangjing/JOL/data/func_data_smooth/standard_sub%d_all.nii',sub_current);
    imgX=nii2x(filename,maskname,idx);
    
    NTR=zeros(3,1); % number of trials in each run
    nRun=3;
    for iRun=1:nRun
        NTR(iRun)=sum(idx(126*(iRun-1)+4:126*iRun-3));
    end
    NTRC=cumsum(NTR); % culmulative sum
    NTRC=[0;NTRC];
    nTrial=NTRC(end);
    
    for iSl=1:nSl
        temp=ix123(ixMask(iSl),sz);
        ix=riSlm+repmat(temp,nPsl,1);
        ix=ix321(ix,sz);
        
        % determine if searchlight is out of the brain
        if min(ix)<1 || max(ix)>size(imgX,2)
            for iRun=1:nRun
                accuracy(iSl,iRun,iSub)=0;
            end
        else
            x=imgX(:,ix);
            
            for iRun=1:nRun
                ix_test=[NTRC(iRun)+1:NTRC(iRun+1)]';
                ix_train=setdiff([1:nTrial]',ix_test);
                
                x_train=x(ix_train,:);
                x_test=x(ix_test,:);
                
                label_train=label(ix_train);
                label_test=label(ix_test);
                
                [x_train,x_test]=norm_zscore(x_train,x_test);
                
                algo='c01_libsvm';
                options=sprintf('-t 0 -q');
                fhandle=str2func(algo);
                label_predict=fhandle(x_train,x_test,label_train,options);
                accuracy(iSl,iRun,iSub)=label2acc(label_test,label_predict);
            end
        end
        clc;
        perct(toc,iSl+(iSub-1)*nSl,nSub*nSl);
    end
end
time=toc/3600;
save(sprintf('demo_searchlight_r%d_%s.mat',r,algo),'accuracy','time');