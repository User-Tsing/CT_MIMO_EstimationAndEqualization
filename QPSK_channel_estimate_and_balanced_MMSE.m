% QPSK信道估计与均衡_Beta，MMSE估计、迫零均衡（可优化）
function [H, handled_signal_ZF, handled_signal_MMSE, judged_symbols_ZF, judged_symbols_MMSE] = QPSK_channel_estimate_and_balanced_MMSE(rx_signal, N, M, fs, sign_num, pilot_num, frame_num, pilot_symbol, SNR_dB)
    % 接收机部分的信道估计与信号均衡算法，匹配滤波后导频波形与原导频波形比对
    % 信号、输出通道数、输入通道数、采样频率、每秒符号数、导频大小、帧大小、导频符号
    % directed by STAssn
    down_num = fs / sign_num; % 每个符号多少点
    frame_all_num = frame_num + pilot_num; % 每帧符号数
    frame_all_num_signal = frame_all_num * down_num; % 每帧信号点数
    N_len = size(rx_signal(:, N)); % 信号长度
    symbol_num = N_len(1) / down_num; % 符号数
    frame = symbol_num / frame_all_num; % 帧数
    H = zeros(N, M, frame);
    pilot_rx = zeros(pilot_num * down_num, N);
    pilot_signal = to_up_sample(pilot_symbol, down_num, M); % 导频符号上采样为信号

    % 导频原信号脉冲成型（？）
    roll_off = 0.7; % 滚降系数
    num_of_symbols = 6; % 截断数
    signal_length = length(pilot_signal); % 符号数（长度）
    fir_rcos_trans = rcosdesign(roll_off, num_of_symbols, down_num, 'sqrt'); % 根升余弦滤波器
    N_fir = length(fir_rcos_trans); % 根升余弦滤波器的长度
    % plot(fir_rcos_trans);
    rcos_data_i_up = randi([0, 1], signal_length, M);
    rcos_data_q_up = randi([0, 1], signal_length, M);
    I_up = real(pilot_signal);
    Q_up = imag(pilot_signal);
    for i = 1:M % 逐通道进行，以防不测
        rcos_data_i_up(:, i) =conv(I_up(:, i), fir_rcos_trans(:), 'same'); % 跟升余弦滚降滤波（不确定因素：本身信号是双通道）
        rcos_data_q_up(:, i) =conv(Q_up(:, i), fir_rcos_trans(:), 'same');
    end
    pilot_signal = rcos_data_i_up + 1i * rcos_data_q_up;
    R_x = (pilot_signal' * pilot_signal) / size(pilot_signal', 2);
    

    noise_power = 10 ^ (- SNR_dB / 10);
    R_n = noise_power * eye(size(R_x, 1));

    % MMSE信道估计
    for i = 1:frame
        for j = 1:N
            pilot_rx(:, j) = rx_signal(((i - 1) * frame_all_num_signal + 1):((i - 1) * frame_all_num_signal + pilot_num * down_num), j); % 接收到的导频符号
        end
        % H(:, :, i) = pilot_rx \ pilot_signal; % LS最小二乘法信道估计算法，得到信道估计矩阵（？），理想状态1*2/(1*2)
        R_y = (pilot_rx' * pilot_rx) / size(pilot_rx, 2);
        R_xy = (pilot_rx' * pilot_signal) / size(pilot_rx, 2); % size == 2
        I = eye(size(R_x));
        H(:, :, i) = R_xy / (R_x + noise_power * I); % MMSE信道估计（变形公式，标准公式疑似为H = R_H * x' * inv(x * R_H * x' + noise_power * I) * y）
    end
    % 迫零均衡
    [handled_signal_ZF, handled_signal_MMSE] = signal_balanced(frame_num, frame, down_num, N, rx_signal, frame_all_num_signal, pilot_num, H, noise_power);
    % 采样判决
    [judged_symbols_ZF, ~, ~] = sampling_and_judge_per_frame(handled_signal_ZF, N, fs, sign_num);
    [judged_symbols_MMSE, ~, ~] = sampling_and_judge_per_frame(handled_signal_MMSE, N, fs, sign_num);
end