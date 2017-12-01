% IQ 7; memory 8; RT 9;

clear all;

% load IQ.txt
% load Memory.txt
% load RT.txt
load DDT218.txt

% imageID=2;
% subID=3;
% effect_size(stroop)=4; the RT difference of INCONG-CONG
% accuracy(stroop)=5;
% accuracy(AntiSaccade)=6;
% SSRT=7;stopsignal effect
% logK=8;
% fitK=9;% used function to fit the delay discounting value
% PCA=10;% principal component of (Stroop, AntiSaccade and Stopsignal)
% gender=1;%1 male 2 female

fac=3; 

isok=1;

% IQ=zscore(IQ);
% Memory=zscore(Memory);
% RT=zscore(RT);

% a=[a IQ Memory RT];
a=sortrows(DDT218,[1,fac]); % first gender, then factor1, 2 or 3

iter=1;
while isok
    iter=iter+1;
    sprintf('iter=%d',iter)
    i=1;
    g=[];
    
    while i < 12 % female 10/group 118
        g=[g randperm(10)];
        i=i+1;
    end

    g=[g randperm(5)]; % additional seven females

    i=1;
    while i < 11; % male 13/group 103
        g=[g randperm(10)];
        i=i+1;
    end
    
    g=[g randperm(3)]; % additional seven males
    % calculate mean
    
        % calculate mean and std
%         [m,s]=grpstats(a(:,fac),g',{'mean','std'});
%         mrange_temp=max(m)-min(m);
%         srange_temp=max(s)-min(s);
%         mstd_temp=std(m);
%         sstd_temp=std(s);
%         
%         if mstd_temp<0.01 && sstd_temp<0.01
%             disp('criterion met!,to group for another factor or to end.')
%             mrange=mrange_temp
%             srange=srange_temp
%             mstd=mstd_temp
%             sstd=sstd_temp
%             
%             tmp=[a(:,fac) g' a(:,2)]
%             tmp=sortrows(tmp,3)
% %             tmp=(:,(1:2))
%             eval(sprintf('save group.txt -ascii -tabs tmp'))
%             isntok=0
%         end
        
%         if mstd>mstd_temp && sstd>sstd_temp
%             disp('find better grouping than ever!')
%             mrange=mrange_temp
%             srange=srange_temp
%             mstd=mstd_temp
%             sstd=sstd_temp
%             tmp=[a(:,fac) g' a(:,2)];
%         end
% end
        
        
     for i=1:10
         m(i)=mean(a(g'==i,fac));
         s(i)=std(a(g'==i,fac));
     end
     
%      sprintf('%f',max(m)-min(m))
%      sprintf('%f',max(s)-min(s))
     if max(m)-min(m)<0.08 & max(s)-min(s) < 0.09
         
         tmp=[a(:,fac) g' a(:,2)];
         tmp=sortrows(tmp,3); tmp=tmp(:,[1:2]);
         eval(sprintf('save DDT218%d.txt -ascii -tabs tmp',fac));
         isok=0;
         
     end
end





    

