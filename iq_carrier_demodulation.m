% 载波解调和匹配滤波
function [symbols, symbols_i, symbols_q] = iq_carrier_demodulation(signal, fs, fc, sign_num, N)
    % 载波调制对应载波解调，脉冲成型对应匹配滤波，在此还存在一个载波同步的问题，再议
    % 接收符号（QPSK/OFDM）多路、载波频率、信号采样频率、每秒发送的符号数、通道数
    % directed by STAssn
    % 载波解调
    N_len = length(signal(: ,1)); % 信号长度
    % plot(signal);
    t = (1 : N_len) / fs; % 采样频率改采样点数
    carrier1 = cos(2 * pi * fc * t);    % 同相载波
    carrier2 = -sin(2 * pi * fc * t);   % 正交载波（本来载波就应该是负正弦）
    carrier1_t = carrier1'; % 为配合双路列向量通道的载波解调，必须也转置成列向量然后才能对位相乘
    carrier2_t = carrier2'; % 为配合双路列向量通道的载波解调，必须也转置成列向量然后才能对位相乘
    I_rx = zeros(N_len, N); % I路初始化
    Q_rx = zeros(N_len, N); % Q路初始化
    for i = 1:N
        I_rx(:, i) = signal(:, i) .* carrier1_t;
        Q_rx(:, i) = signal(:, i) .* carrier2_t;
    end
    % plot(I_rx);
    % plot(Q_rx);
    symbols_mid = I_rx + 1i * Q_rx; % 复数中间态

    % 匹配滤波
    % 匹配滤波即是对前置的脉冲成型函数进行时域变换h*(T-t)，按照原理，可能有T=1/Fc？主要是为了同步，这里暂且不用直接反转共轭
    roll_off = 0.7; % 滚降系数
    num_of_symbols = 6; % 截断数
    up_num = fs / sign_num; % 采样频率与每秒发送的符号数求比值，得到每符号采样点数
    signal_length = length(symbols_mid); % 符号数（长度）
    fir_rcos_trans = rcosdesign(roll_off, num_of_symbols, up_num, 'sqrt'); % 根升余弦滤波器
    match_filter = flip(fir_rcos_trans); % 时间反转
    match_filter_conj = conj(match_filter); % 取共轭（然而真的是这样吗？）
    symbols_i = zeros(N_len, N);
    symbols_q = zeros(N_len, N);
    for i = 1:N
        symbols_i(:, i) = conv(I_rx(:, i), match_filter_conj, 'same'); % 滤波，也有说用xcorr()交叉相关的？
        symbols_q(:, i) = conv(Q_rx(:, i), match_filter_conj, 'same'); % 滤波，也有说用xcorr()交叉相关的？
        % symbols = filter(symbols_mid(:, i), 1, match_filter_conj);
    end
    % plot(symbols_i);
    % plot(symbols_q);
    symbols = symbols_i + 1i * symbols_q; % 复数中间态
end