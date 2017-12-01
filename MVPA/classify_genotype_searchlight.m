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
maskname='/expdata/chunhui/zang/vbm/vbm_cw/stats/GM_mask.nii';
basedir ='/expdata/chunhui/zang/vbm/vbm_cw/stats/';
filename=sprintf('%sGM_mod_merg_s3.nii',basedir);
idx=[ones(281,1)];
imgX=nii2x(filename,maskname,idx);

nii=load_untouch_nii(maskname);
img=nii.img;
sz=size(img);
ixMask=find(img);
nSl=sum(img(:));

para=1000;
voxelaccuracy=zeros(1,nSl); % check if nSl is number of voxels
tic;

    load BDNFCOMT10group;
    genotype=data(:,6);
    group=data(:,9);
    
    for iSl=1:nSl  % searchlight for each voxel
        iSl
        temp=ix123(ixMask(iSl),sz);
        ix=riSlm+repmat(temp,nPsl,1);
        ix=ix321(ix,sz);
        
        % determine if searchlight is out of the brain
        if 0 % ~all(ismember(ix,ixMask))  % min(ix)<1 || max(ix)>size(imgX,2)
            voxelaccuracy(iSl)=0;
        else
            x=imgX(:,find(ismember(ixMask,ix))); %imgX(:,ix);
            predic10=[]; actural10=[];

            for gidx=1:10 % 10 groups leave one out
                idx_test=find(group==gidx);
                idx_train=find(group~=gidx);
                label_test=genotype(idx_test);
                label_train=genotype(idx_train);%[ones(1,30) ones(1,30)*2 ones(1,30)*3 ]';

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
                end
                predic10=[predic10; label_predict];
                actural10=[actural10; label_test];
            end
            voxelaccuracy(iSl)=length(find((predic10-actural10)==0))/length(actural10);

        end
     %   clc;
    end
 x2nii(voxelaccuracy,maskname,'accuracy_BDNFCOMT.nii');

