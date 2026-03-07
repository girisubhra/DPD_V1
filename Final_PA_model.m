clc;
clear all;
close all;
tic;
Filepath='D:\PhD_Project\Correctly_Working_DPD\25Watt_PA\GMP_Model_output';



Input_IComp=readmatrix('D:\PhD_DPD_Project\DPD_V1\7_Ydpd_I_Sample.xlsx');
Input_QComp=readmatrix('D:\PhD_DPD_Project\DPD_V1\8_Ydpd_Q_Sample.xlsx');
Xact=Input_IComp(:,1)+1j*Input_QComp(:,1);


% ------------- Loss Compensated -----------  %
Output_IComp=readmatrix('D:\PhD_DPD_Project\DPD_V1\Output_I.xlsx');
Output_QComp=readmatrix('D:\PhD_DPD_Project\DPD_V1\Output_Q.xlsx');
Yact=Output_IComp(:,1)+1j*Output_QComp(:,1);


% %-----------------------------Model Testing----------------------------%
% 
for ii=1:length(Xact)
    testsamp(ii)=10+ii;%start from 500 samples
end
%{
Ka=5;
La=3;

Kb=3;
Lb=3;

Mb=2;
Kc=3;

Lc=3;
Mc=2;
%}
Ka=7;
La=4;
Kb=5;
Lb=2;
Mb=3;
Kc=5;
Lc=2;
Mc=3;% obtained by optimizing
ncoef=((Ka+1)*(La+1))+(Kb*(Lb+1)*Mb)+(Kc*(Lc+1)*Mc);

ntest=9980; % No of samples used for testing
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


% %----------------------Least squares prediction-----------------------%

Coeff_ls=readmatrix('D:\PhD_DPD_Project\DPD_V1\PA_Co-efficient.txt');
Ypredict=Theta_test*Coeff_ls;

% NMSENum=0;
% NMSEDen=0;
% for co=1:500
%         NMSENum=NMSENum+(abs(Ypredict(co)-Yact_test(co))^2);
%         NMSEDen=NMSEDen+(abs(Yact_test(co))^2);
% end
% NMSE=10*log10(NMSENum/NMSEDen);
a = real(Ypredict);
writematrix(a,'D:\PhD_DPD_Project\DPD_V1\9_PA_Out_I_smple.xlsx')

b = imag(Ypredict);
writematrix(b,'D:\PhD_DPD_Project\DPD_V1\10_PA_Out_Q_smple.xlsx')
%display(b);
c = real(Yact_test);
writematrix(c,'D:\PhD_DPD_Project\DPD_V1\11_PA_IN_I_sample.xlsx')
%display(c);
d = imag(Yact_test);
writematrix(d,'D:\PhD_DPD_Project\DPD_V1\12_PA_IN_Q_sample.xlsx')
%display(d);
figure()
%subplot(2,1,1);
plot(b(1:500),'r');
hold on;
plot(d(1:500),'b');
legend('Predicted  Q Sample','Test Q Sample');
% hold on;
% subplot(2,1,2);
% plot(a(1:500),'r');
% hold on;
% plot(c(1:500),'b');
% legend('Predicted  I Sample','Test I Sample')
display('Finished Execution');
elapsed_time = toc;
disp(['Elapsed time: ', num2str(elapsed_time), ' seconds']);
