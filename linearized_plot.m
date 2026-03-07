
I_in=readmatrix('D:\PhD_DPD_Project\DPD_V1\Input_I.xlsx');
Q_in=readmatrix('D:\PhD_DPD_Project\DPD_V1\Input_Q.xlsx');

I_out=readmatrix('D:\PhD_DPD_Project\DPD_V1\Output_I.xlsx');
Q_out=readmatrix('D:\PhD_DPD_Project\DPD_V1\Output_Q.xlsx');


% - ------------- Linearized output Compensated ----------------      %
Lin_I=readmatrix('D:\PhD_DPD_Project\DPD_V1\Input_I.xlsx');
Lin_Q=readmatrix('D:\PhD_DPD_Project\DPD_V1\Input_Q.xlsx');

Lout_I=readmatrix('D:\PhD_DPD_Project\DPD_V1\9_PA_Out_I_smple.xlsx');
Lout_Q=readmatrix('D:\PhD_DPD_Project\DPD_V1\10_PA_Out_Q_smple.xlsx');

I_in=I_in(50011:59010,1);
Q_in=Q_in(50011:59010,1);

I_out=I_out(50011:59010,1);
Q_out=Q_out(50012:59011,1);

Lin_I=Lin_I(50011:59010,1);
Lin_Q=Lin_Q(50011:59010,1);


Lout_I=Lout_I(1:9000);
Lout_Q=Lout_Q(1:9000);



P1=sqrt(Lin_I.^2 + Lin_Q.^2);
Q1=sqrt(Lout_I.^2 + Lout_Q.^2);

Mag_in=sqrt(I_in.^2 + Q_in.^2);
Mag_out=sqrt(I_out.^2 + Q_out.^2);
X1=Mag_in;
Y1=Mag_out;



figure(1)
plot(10*X1,'r');
hold on;
plot(10*Y1,'b');
hold on;
plot(Q1,'g')
legend('Mag\_in','Mag\_Out','Mag\_Lin\_out');
xlim([0,300]);


[correlation, lags] = xcorr(X1, Q1);
[~, max_idx] = max(abs(correlation));
lag = lags(max_idx);

if lag > 0
    Q1_synchronized = Q1(lag+1:end);
    X1_truncated = X1(1:end-lag);
else
    lag_abs = abs(lag);
    Q1_synchronized = Q1(1:end-lag_abs);
    X1_truncated = X1(lag_abs+1:end);
end

figure()
scatter(X1_truncated,Q1_synchronized);

figure()
[c,lags] = xcorr(Q1_synchronized,X1_truncated);
stem(lags,c)
xlim([-20,20]);
title('Cross Corelation')


figure(3)
scatter(X1, Y1)
hold on;
scatter(P1, Q1,'filled', 'MarkerFaceColor', 'r');
xlabel('Pin');
ylabel('Pout');
legend('\fontsize{9} Without DPD','\fontsize{9} With DPD');
title('Linearized Output With DPD');

%------------------------Pin/Pout before Linearization -----------------------------------%
Pin=10*log10(abs(X1).^2)/.1;
Pout=10*log10(abs(Y1).^2)/.1;
figure(4)
scatter(Pin,Pout);
title('Pin/Pout before Linearization');
%------------------------Pin/Pout after Linearization -----------------------------------%
Pin=10*log10(abs(X1).^2)/.1;
Pout=10*log10(abs(Q1).^2)/.1;
figure(5)
scatter(Pin,Pout);
title('Pin/Pout after Linearization');

%------------------------Pin/Pout after Linearization -----------------------------------%
Pin=10*log10(abs(X1_truncated).^2)/.1;
Pout=10*log10(abs(Q1_synchronized).^2)/.1;
figure(5)
scatter(Pin,Pout);
title('Pin/Pout after Linearization');
%-------------------------------%
fs = 100e6; % 30 MHz sampling frequency
bandwidth = 40e6; % 30 MHz bandwidth for display
window_length = 1024; % Increased for better resolution
noverlap = window_length/2;
nfft = 4096; % Increased for better frequency resolution

% Calculate PSD for complex signals with 'centered' option
[Pxx_input, f_input] = pwelch(X1, hamming(window_length), noverlap, nfft, fs, 'centered');
[Pxx_output, f_output] = pwelch(Y1, hamming(window_length), noverlap, nfft, fs, 'centered');

% Single comprehensive plot
figure()
plot(f_input/.125e6, 10*log10(Pxx_input), 'b-', 'LineWidth', 2.5, 'DisplayName', 'Input Signal')
hold on
plot(f_output/.125e6, 10*log10(Pxx_output), 'r-', 'LineWidth', 2.5, 'DisplayName', 'Output Signal')
xticks(-60:15:60);
xlim([-300,300])
%{
% Formatting
title('Power Spectral Density Comparison ', ...
      'FontSize', 14, 'FontWeight', 'bold')
xlabel('Frequency (MHz)', 'FontSize', 12, 'FontWeight', 'bold')
ylabel('Power Spectral Density (dB/Hz)', 'FontSize', 12, 'FontWeight', 'bold')
legend('Location', 'best', 'FontSize', 10)
grid on
% xlim([-bandwidth/2/.25e6, bandwidth/2/.25e6])
% ylim([-150, -50]) % Adjust based on your signal

% Add vertical lines at bandwidth boundaries
xline(-40, 'k--', 'LineWidth', 1.5, 'Alpha', 0.7, 'DisplayName', '±15MHz Boundary');
xline(40, 'k--', 'LineWidth', 1.5, 'Alpha', 0.7, 'HandleVisibility', 'off');
%}
