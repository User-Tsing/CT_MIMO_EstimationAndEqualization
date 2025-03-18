% 脉冲成型和载波调制，适用于QPSK/OFDM（OFDM要拼接好）（？）
function [tx_signal, I_up, Q_up, I_signal, Q_signal] = iq_carrier_modulation(symbols, M, fs, fc, sign_num)
    % 根升余弦滤波以进行脉冲成型，I/Q双路调制以产生模拟信号
    % 输入符号（QPSK/OFDM）多路、通道数、载波频率、信号采样频率、每秒发送的符号数
    % directed by STAssn
    % M = 2;
    N_len = length(symbols(:, 1)); % 暂定两路通道的信号是一样长的，只取一路看长度

    % 分路（复数矩阵虚实分离）
    I_sym = zeros(N_len, M);
    Q_sym = zeros(N_len, M);
    for i = 1:M
        I_sym(:, i) = real(symbols(:, i)); % 实部I路
        Q_sym(:, i) = imag(symbols(:, i)); % 虚部Q路
    end

    % 上采样扩展数组
    up_num = fs / sign_num; % 采样频率与每秒发送的符号数求比值，得到每符号采样点数
    I_up = to_up_sample(I_sym, up_num, M); % 符号扩展
    Q_up = to_up_sample(Q_sym, up_num, M); % 符号扩展

    % 脉冲成型部分
    roll_off = 0.7; % 滚降系数
    num_of_symbols = 6; % 截断数
    signal_length = N_len; % 符号数（长度）
    fir_rcos_trans = rcosdesign(roll_off, num_of_symbols, up_num, 'sqrt'); % 根升余弦滤波器
    N_fir = length(fir_rcos_trans); % 根升余弦滤波器的长度
    % plot(fir_rcos_trans);
    rcos_data_i_up = randi([0, 1], signal_length * up_num, M);
    rcos_data_q_up = randi([0, 1], signal_length * up_num, M);
    for i = 1:M % 逐通道进行，以防不测
        rcos_data_i_up(:, i) =conv(I_up(:, i), fir_rcos_trans(:), 'same'); % 跟升余弦滚降滤波（不确定因素：本身信号是双通道）
        rcos_data_q_up(:, i) =conv(Q_up(:, i), fir_rcos_trans(:), 'same');
        % 另一种玩法（？）
        % rcos_data_i_up(:, i) = upfirdn(I_up(:, i), fir_rcos_trans, up_num);
        % rcos_data_q_up(:, i) = upfirdn(Q_up(:, i), fir_rcos_trans, up_num);
        N = length(rcos_data_i_up(: ,i));
    end

    % I/Q双通道载波调制
    % 由于这里不进行间断操作，为确保每个符号波形正常，载波频率应为每秒发送符号数的整数倍
    t = (1 : N) / fs;
    carrier1 = cos(2 * pi * fc * t);    % 同相载波
    carrier2 = -sin(2 * pi * fc * t);   % 正交载波
    carrier1_t = carrier1'; % 为配合双路列向量通道的载波调制，必须也转置成列向量然后才能对位相乘
    carrier2_t = carrier2'; % 为配合双路列向量通道的载波调制，必须也转置成列向量然后才能对位相乘
    signal = randi([0, 1], signal_length * up_num, M);
    I_signal = randi([0, 1], signal_length * up_num, M);
    Q_signal = randi([0, 1], signal_length * up_num, M);
    for i = 1:M
        signal(:, i) = rcos_data_i_up(:, i) .* carrier1_t + rcos_data_q_up(:, i) .* carrier2_t; % 逐通道进行，得出最终QPSK结果
        I_signal(:, i) = rcos_data_i_up(:, i) .* carrier1_t;
        Q_signal(:, i) = - rcos_data_q_up(:, i) .* carrier2_t;
    end
    % plot(I_signal);
    % plot(Q_signal);
    tx_signal = signal; % 最终输出信号（？）
end