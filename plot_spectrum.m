clc
close all
clear all

%% Read csv file
% T = readtable('80_GAIN_10_data_csv.csv');
% D = table2array(T(1:end,2:end));
% B = zeros(length(D(:,1)),length(D(1,:)));
% for i = 1:length(D(:,1))
%     for j = 1:length(D(1,:))
%         A =cell2mat(D(i,j));
%         if A(1) == '('
%             B(i,j) = str2double(A(2:(end-1)));
%         else
%             B(i,j) = str2double(D(i,j));
%         end
%     end
% end
% C = T.Var1;
% final_matrix = cat(2,C,B);

%% Load converted file
load 80DB_antenna_data.mat

%% Reshaping into 3D matrix (samples per second*no of channels*total time)
final_matrix_3D = reshape(B,length(B(:,1))/10,59,10);
%final_matrix_1D = reshape(final_matrix_3D(:,:,3),18645*59,1);

Win2D = hanning(length(final_matrix_3D(:,1,1)));
Win2D = repmat(Win2D,1,length(final_matrix_3D(1,:,1))); %for windowing the raw signal

%% zero frequency clutter suppression with MTI
freq = -pi : pi/2048 : pi-1/4096;
two_pulse_canceller = 1-exp(-1i*freq);
%two_pulse_canceller_2D = repmat(two_pulse_canceller,length(B(1,:)),1);
NFFT =4096; %no of frequency points used

for i = 1:length(final_matrix_3D(1,1,:))
    T_fft(:,:,i) = fftshift(fft(final_matrix_3D(:,:,i),NFFT,1));
    %T_fft(:,:,i) = T_fft(:,:,i).*two_pulse_canceller_2D.';
end
t = 5; %time in seconds(change the time as you like from 1 to 10)

i = 2450; %center frequency(change the center frequency as you like)

k = (i-50)/50; %channel number (100MHz is channel no 1 and 3GHz is 59)
T_fft_2D = T_fft(:,:,t); %taking only the "t"th second data for all the channels
T_PSD = T_fft_2D.*conj(T_fft_2D)/NFFT; %calculating power spectrum density
T_PSD_1D = reshape(T_PSD,4096*59,1); %showing all the channels in the "t" th second
x_2D = i-25:(50/4096):(i+25)-1/4096; %frequency points for 1 channel only
x_1D = 75:50/4096:3025-1/4096; %converting frequency points for all the channels combined

figure
subplot(2,1,1)
plot(x_2D,abs(T_PSD(:,k))); %plotting it for "K" channel and "t" th second 
% xticks([1 2048 4096])
% xticklabels({i-25,i,i+25})
xlabel('frequency points');
ylabel('PSD');
str = sprintf('PSD for %d MHz center frequency',i);
title(str);

subplot(2,1,2)
plot(x_1D,abs(T_PSD_1D)); %plotting it for "K" channel and "t" th second 
xlim([75 3025]);
xlabel('frequency points');
ylabel('PSD');
title('PSD for whole frequency spectrum');
% xticks([1:4096:4096*59])
% xticklabels({i-25,i,i+25})

% figure
% surf(abs(T_PSD)); %seeing all the channels for a fixed "t"th second


