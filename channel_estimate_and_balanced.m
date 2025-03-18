% 信道估计与均衡，LS估计，迫零均衡（可优化）
function [H, handled_signal] = channel_estimate_and_balanced(rx_signal, N, M, fs, sign_num, pilot_num, frame_num, pilot_symbol)
    % 接收机部分的信道估计与信号均衡算法，目前得到完整接收信号波形（匹配滤波后），目前看到的说法是，先采样判决得到导频符号后和原导频符号比对
    % 信号、输出通道数、输入通道数、采样频率、每秒符号数、导频大小、帧大小、导频符号
    % directed by STAssn
    [get_symbols, ~, ~] = sampling_and_judge_per_frame(rx_signal, N, fs, sign_num); % 先采样判决一次
    frame_all_num = frame_num + pilot_num;
    N_len = size(get_symbols(:, N));
    frame = N_len(1) / frame_all_num; % 帧数
    H = zeros(N, M, frame);
    pilot_rx = zeros(pilot_num, N);
    % LS信道估计
    for i = 1:frame
        for j = 1:N
            pilot_rx(:, j) = get_symbols(((i - 1) * frame_all_num + 1):((i - 1) * frame_all_num + pilot_num), j); % 接收到的导频符号
        end
        H(:, :, i) = pilot_symbol \ pilot_rx; % LS最小二乘法信道估计算法，得到信道估计矩阵（？），理想状态1*2/(1*2)
        % H(:, :, i) = (pilot_symbol' * pilot_symbol) \ pilot_symbol' * pilot_rx; % LS最小二乘法信道估计算法原版，效果离谱原因不明
    end
    % 迫零均衡
    handled_signal = zeros(frame_num * frame, N);
    signal_mid = zeros(frame_num, N); % 中间变量。单帧数据
    for i = 1:frame
        signal_mid(:, :) = get_symbols(((i - 1) * frame_all_num + 1 + pilot_num):(i * frame_all_num), :); % 脱离导频，只留下信号
        pseudo_inverse_matrix = pinv(H(:, :, i));
        % handled_signal(((i - 1) * frame_num + 1):(i * frame_num), :) = (pseudo_inverse_matrix * signal_mid')'; % 迫零均衡（？）
        handled_signal(((i - 1) * frame_num + 1):(i * frame_num), :) =  signal_mid * pseudo_inverse_matrix; % 迫零均衡（？）
    end
end