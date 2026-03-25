% Read input data
I_in=readmatrix('D:\PhD_DPD_Project\DPD_V1\Input_I.xlsx');
Q_in=readmatrix('D:\PhD_DPD_Project\DPD_V1\Input_Q.xlsx');
X=I_in(:,1)+1j*Q_in(:,1);

I_out=readmatrix('D:\PhD_DPD_Project\DPD_V1\Output_I.xlsx');
Q_out=readmatrix('D:\PhD_DPD_Project\DPD_V1\Output_Q.xlsx');
Y=I_out(:,1)+1j*Q_out(:,1);

% Lout_I=readmatrix('D:\PhD_DPD_Project\DPD_V1\9_PA_Out_I_smple.xlsx');
% Lout_Q=readmatrix('D:\PhD_DPD_Project\DPD_V1\10_PA_Out_Q_smple.xlsx');
% Z=Lout_I(:,1)+1j*Lout_Q(:,1);

% Take first 70000 samples
% I_in=I_in(1:70000,1);
% Q_in=Q_in(1:70000,1);
% I_out=I_out(1:70000,1);
% Q_out=Q_out(1:70000,1);

I_in=I_in(50011:59010,1);
Q_in=Q_in(50011:59010,1);
I_out=I_out(50011:59010,1);
Q_out=Q_out(50011:59010,1);

% I_Lin=Lout_I(1:70000,1);
% Q_Lin=Lout_Q(1:70000,1);
% Calculate magnitudes and phases
Mag_in=sqrt(I_in.^2 + Q_in.^2);
Mag_out=sqrt(I_out.^2 + Q_out.^2);
% Mag_lin=sqrt(I_Lin.^2+Q_Lin.^2);

Phase_in = unwrap(angle(I_in + 1j*Q_in));
Phase_out = unwrap(angle(I_out + 1j*Q_out));

% Calculate phase difference (AM/PM)
Phase_diff = Phase_out - Phase_in;
% Normalize phase difference to [-pi, pi]
Phase_diff = mod(Phase_diff + pi, 2*pi) - pi;

% Convert to degrees for better visualization
Phase_diff_deg = Phase_diff * 180/pi;

% Calculate input power in dBm (assuming 50 ohm system)
Pin = 10*log10(Mag_in.^2/50) + 30; % Converts to dBm
% Alternative if you want the original calculation:
% Pin=10*log10(abs(X1).^2)/.1;

% Remove outliers and sort data for better visualization
% Sort by input magnitude for clean plots
[Pin_sorted, sort_idx] = sort(Pin);
Mag_out_sorted = Mag_out(sort_idx);
Phase_diff_sorted = Phase_diff_deg(sort_idx);

% Create figure with two subplots
%figure('Position', [100, 100, 1200, 500])
%{
% AM/AM Plot
subplot(1,2,1)
plot(Pin, 20*log10(Mag_out), '.', 'MarkerSize', 3)
% Alternative: plot(Pin, Mag_out, '.')
xlabel('Input Power (dBm)', 'FontSize', 12)
ylabel('Output Power (dBm)', 'FontSize', 12)
title('AM/AM Characteristics', 'FontSize', 14)
grid on
xlim([min(Pin) max(Pin)])
% Add ideal linear response line for reference
hold on
plot([min(Pin) max(Pin)], [min(Pin) max(Pin)], 'r--', 'LineWidth', 2)
legend('Measured', 'Ideal', 'Location', 'best')
%}

% AM/PM Plot
% subplot(1,2,2)
% plot(Pin, Phase_diff_deg, '.', 'MarkerSize', 3)
% xlabel('Input Power (dBm)', 'FontSize', 12)
% ylabel('Phase Shift (degrees)', 'FontSize', 12)
% title('AM/PM Characteristics', 'FontSize', 14)
% grid on
% xlim([min(Pin) max(Pin)])

figure()
plot(Pin, Phase_diff_deg, '.', 'MarkerSize', 3)
xlabel('Input Power (dBm)', 'FontSize', 12)
ylabel('Phase Shift (degrees)', 'FontSize', 12)
title('AM/PM Characteristics', 'FontSize', 14)
grid on
xlim([-10 35])
%xlim([min(Pin) max(Pin)])
%{
% Add some statistics
sgtitle(sprintf('PA Characteristics - Max Phase Shift: %.2f°', ...
    max(abs(Phase_diff_deg))), 'FontSize', 16)

% Optional: Create a second figure with scatter plots colored by density
figure('Position', [100, 100, 1200, 500])

% Density-based AM/AM
subplot(1,2,1)
scatter(Pin, 20*log10(Mag_out), 5, 'filled', 'MarkerFaceAlpha', 0.5)
xlabel('Input Power (dBm)', 'FontSize', 12)
ylabel('Output Power (dBm)', 'FontSize', 12)
title('AM/AM - Density View', 'FontSize', 14)
grid on
colorbar
colormap(gca, jet)

% Density-based AM/PM
subplot(1,2,2)
scatter(Pin, Phase_diff_deg, 5, 'filled', 'MarkerFaceAlpha', 0.5)
xlabel('Input Power (dBm)', 'FontSize', 12)
ylabel('Phase Shift (degrees)', 'FontSize', 12)
title('AM/PM - Density View', 'FontSize', 14)
grid on
colorbar
colormap(gca, jet)

% Optional: Calculate and display key metrics
fprintf('=== PA Characteristics Summary ===\n');
fprintf('Input Power Range: %.2f to %.2f dBm\n', min(Pin), max(Pin));
fprintf('Output Power Range: %.2f to %.2f dBm\n', min(20*log10(Mag_out)), max(20*log10(Mag_out)));
fprintf('Maximum Phase Shift: %.2f degrees\n', max(abs(Phase_diff_deg)));
fprintf('Average Phase Shift: %.2f degrees\n', mean(abs(Phase_diff_deg)));

% Optional: Save the figures
% saveas(gcf, 'PA_Characteristics.png');
%}