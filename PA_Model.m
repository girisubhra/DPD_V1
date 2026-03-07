clc;
clear all;
close all;
tic;


%% TX Data %%%%%%

I_input_data=readmatrix('D:\PhD_DPD_Project\DPD_V1\Input_I.xlsx');
Q_input_data=readmatrix('D:\PhD_DPD_Project\DPD_V1\Input_Q.xlsx');
Xact=I_input_data(:,1)+1j*Q_input_data(:,1);
X1=Xact;

X=I_input_data(1:70000,1);
Y=Q_input_data(1:70000,1);
Mag_in=sqrt(X.^2 + Y.^2);


%% RX Data %%%%%%

Output_IComp=readmatrix('D:\PhD_DPD_Project\DPD_V1\Output_I.xlsx');
Output_QComp=readmatrix('D:\PhD_DPD_Project\DPD_V1\Output_Q.xlsx');
Yact=Output_IComp(:,1)+1j*Output_QComp(:,1);
Yact=Yact;
Y1=Yact;

X=Output_IComp(1:70000,1);
Y=Output_QComp(1:70000,1);
Mag_out=sqrt(X.^2 + Y.^2);


figure()
plot(Mag_in,'b');
hold on;
plot(Mag_out,'r');
legend('Input Signal','Output Signal');
title('Magnitude plot of Input and Output Signal Before Time Delay Synch');
xlim([1,300]);

X1=Mag_in;
Y1=Mag_out;

[correlation, lags] = xcorr(Y1, X1);
[~, max_idx] = max(abs(correlation));
lag = lags(max_idx); % Lag in samples
if lag > 0
    Y1_synchronized = Y1(lag+1:end);% Y1_synchronized = Y1(lag+1:end);
    X1_truncated = X1(1:end-lag);
else
    lag_abs = abs(lag);
    Y1_synchronized = Y1(1:end-lag_abs);
    X1_truncated = X1(lag_abs+1:end);
end

% 
figure()
[c,lags] = xcorr(X1,Y1);
%[c,lags] = xcorr(X1);  %For auto-correlation 
stem(lags,c)
xlim([-200,200]);

% Magnitude Plot of Input and Output Signal After Time Delay Compensation %%
figure()
plot(X1_truncated(1:600),'b');
hold on;
plot(Y1_synchronized(1:600),'r');
legend('Input Signal','Output Signal');
title('After Time Delay Compensation')

figure()
plot(abs(X1_truncated(1:10000)),10*abs((Y1_synchronized(1:10000))),'.r');
grid on;
xlabel('Magnitude of Input (dB)', 'FontSize', 12, 'FontWeight', 'bold')
ylabel('Magnitude of Output (dB)', 'FontSize', 12, 'FontWeight', 'bold')
title('Scatter plot After Time Delay Compensation')

%-----------------------------GMP model----------------------------%
% 

for ii=1:length(Xact)
    trainsamp(ii)=500+ii; %start from 900 samples 900+ii
end

Ka=5;
La=3;

Kb=3;
Lb=3;

Mb=2;
Kc=3;

Lc=3;
Mc=2;

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
writematrix(Coeff_ls,'D:\PhD_DPD_Project\DPD_V1\PA_Co-efficient.txt');
% 
% 
% %-----------------------------Model Testing----------------------------%
% 
for ii=1:length(Xact)
    testsamp(ii)=50000+ii;%start from 1000 samples
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

% %----------------------Least squares prediction-----------------------%
Ypredict=Theta_test*Coeff_ls;
NMSENum=0;
NMSEDen=0;
for co=1:5000
        NMSENum=NMSENum+(abs(Ypredict(co)-Yact_test(co))^2);
        NMSEDen=NMSEDen+(abs(Yact_test(co))^2);
end
NMSE=10*log10(NMSENum/NMSEDen);

a = real(Ypredict);
writematrix(a,'D:\PhD_DPD_Project\DPD_V1\3_PA_Out_I_smple.xlsx')

b = imag(Ypredict);
writematrix(b,'D:\PhD_DPD_Project\DPD_V1\4_PA_Out_Q_smple.xlsx')

% display(b);
c = real(Yact_test);
writematrix(c,'D:\PhD_DPD_Project\DPD_V1\1_PA_IN_I_sample.xlsx')


%display(c);
d = imag(Yact_test);
writematrix(d,'D:\PhD_DPD_Project\DPD_V1\2_PA_IN_Q_sample.xlsx')

figure()
plot(b(1:500),'r');
hold on;
plot(d(1:500),'b');

figure()
plot(a(1:500),'r');
hold on;
plot(c(1:500),'b');

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
legend('Predicted  I Sample','Test I Sample');
%display(d);

display('Finished Execution');
elapsed_time = toc;
disp(['Elapsed time: ', num2str(elapsed_time), ' seconds']);

