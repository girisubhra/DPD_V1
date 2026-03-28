%%------------------------convert to complex baseband-----------------------%
clc;
clear all;
close all;

tic;

Input_IComp=readmatrix('D:\PhD_DPD_Project\DPD_V1\Output_I.xlsx');
Input_QComp=readmatrix('D:\PhD_DPD_Project\DPD_V1\Output_Q.xlsx');
Xact=Input_IComp(:,1)+1j*Input_QComp(:,1);

Output_IComp=readmatrix('D:\PhD_DPD_Project\DPD_V1\Input_I.xlsx');
Output_QComp=readmatrix('D:\PhD_DPD_Project\DPD_V1\Input_Q.xlsx');
Yact=Output_IComp(:,1)+1j*Output_QComp(:,1);


Gain= 7.08;
Xact=Xact/Gain;

%-----------------------------GMP model----------------------------%

for ii=1:length(Xact)
    trainsamp(ii)=500+ii;%start from 500 samples
end

% Ka=5;
% La=3;
% 
% Kb=3;
% Lb=3;
% 
% Mb=2;
% Kc=3;
% 
% Lc=3;
% Mc=2;
Ka=7;La=5;Kb=5;Lb=3;Mb=3;Kc=5;Lc=3;Mc=3;%ncoef=168
ncoef=((Ka+1)*(La+1))+(Kb*(Lb+1)*Mb)+(Kc*(Lc+1)*Mc);

nmodel=12000; % No of samples used for modeling
for i=1:nmodel
    n=trainsamp(i);
    j=1;
    for k=0:Ka
       for l=0:La
            Theta(i,j)=Xact(n-l)*(abs(Xact(n-l))^k);  
            j=j+1;
       end
    end
    for k=1:Kb
       for l=0:Lb
           for m=1:Mb
               Theta(i,j)=Xact(n-l)*(abs(Xact(n-l-m))^k);  
               j=j+1;
           end 
       end
    end
    for k=1:Kc
       for l=0:Lc
           for m=1:Mc
               Theta(i,j)=Xact(n-l)*(abs(Xact(n-l+m))^k);  
               j=j+1;
           end 
       end
    end
   Yact_v(i,1)=Yact(n);% Yact should be a vector for least squares operation
end
Coeff_ls=pinv(Theta'*Theta)*Theta'*Yact_v; 
writematrix(Coeff_ls,'D:\PhD_DPD_Project\DPD_V1\DPD_Co-efficient.txt');


%-----------------------------Model Testing----------------------------%

for ii=1:length(Xact)
    testsamp(ii)=50000+ii;%start from 20000 samples
end


ntest=10000; % No of samples used for testing
for i=1:ntest
    nn=testsamp(i);
    j=1;
    for k=0:Ka
       for l=0:La
            Theta_test(i,j)=Xact(nn-l)*(abs(Xact(nn-l))^k);  
            j=j+1;
       end
    end
    for k=1:Kb
       for l=0:Lb
           for m=1:Mb
               Theta_test(i,j)=Xact(nn-l)*(abs(Xact(nn-l-m))^k);  
               j=j+1;
           end 
       end
    end
    for k=1:Kc
       for l=0:Lc
           for m=1:Mc
               Theta_test(i,j)=Xact(nn-l)*(abs(Xact(nn-l+m))^k);  
               j=j+1;
           end 
       end
    end
   Yact_test(i,1)=Yact(nn,1);% Yact_test should be a vector for least squares operation
end


%----------------------Least squares prediction-----------------------%
Ypredict=Theta_test*Coeff_ls;
% NMSENum=0;
% NMSEDen=0;
% for co=1:4100
%         NMSENum=NMSENum+(abs(Ypredict(co)-Yact_test(co))^2);
%         NMSEDen=NMSEDen+(abs(Yact_test(co))^2);
% end
% NMSE=10*log10(NMSENum/NMSEDen);

a = real(Ypredict);
writematrix(a,'D:\PhD_DPD_Project\DPD_V1\5_Ydpd_I_Sample.xlsx')
b = imag(Ypredict);
writematrix(b,'D:\PhD_DPD_Project\DPD_V1\6_Ydpd_Q_Sample.xlsx')
%display(b);
c = real(Yact_test);
writematrix(c,'D:\PhD_DPD_Project\DPD_V1\Xdpd_I_Sample.xlsx')
%display(c);
d = imag(Yact_test);
writematrix(d,'D:\PhD_DPD_Project\DPD_V1\Xdpd_Q_Sample.xlsx')

%display(d);
figure()
subplot(2,1,1);
plot(b(1:500),'r');
hold on;
plot(d(1:500),'b');
legend('Predicted  Q Sample','Test Q Sample');
hold on;
subplot(2,1,2);
plot(a(1:500),'r');
hold on;
plot(c(1:500),'b');
legend('Predicted  I Sample','Test I Sample')
display('Finished Execution');
elapsed_time = toc;
disp(['Elapsed time: ', num2str(elapsed_time), ' seconds']);