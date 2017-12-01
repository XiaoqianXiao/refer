clear,clc
cd /seastor/chunhui/zhaolbrest/Results/FC
% sublist=101:120
% r=nan(length(sublist),1)
idx=0
for sub=101:120
   idx=idx+1;
   load(['ROI_FCMap_sub' num2str(sub) '.mat']) 
   [r(:,:,idx) p(:,:,idx)]=corr(SeedSeries);
end
r=r([3 4 5 1 6 7 8 2],[3 4 5 1 6 7 8 2],:) % to libo order


z=0.5*log((1+r)./(1-r));
meanz=mean(z,3);
meanr=(exp(2*meanz)-1)./(exp(2*meanz)+1);

% meanz=meanz([3 4 5 1 6 7 8 2],[3 4 5 1 6 7 8 2]) % to libo order
% meanr=meanr([3 4 5 1 6 7 8 2],[3 4 5 1 6 7 8 2]) % to libo order
save RestCorrelation r meanz meanr
% save meanz meanz