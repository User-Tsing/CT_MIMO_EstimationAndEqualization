% 3.  信道估计与均衡算法
% 第一级：完成面向多入多出系统（2个数据流，QPSK调制）接收端的信道估计（自行设计导频和帧结构）
% 与信号均衡算法(破零均衡)的软件实现,
% 完成功能验证（50分）
% 第二级：上述系统的信道估计（10分）与信号均衡（10分）算法的硬件实现，与软件实现结果进行对比分析（10分）
% 第三级：设计该系统的最佳接收机，并完成软件（10分）和硬件（10分）的功能实现；
% 基于LTE-R12标准重新设计上述信道估计与信号均衡算法，并完成软件（10分）和硬件（10分）的功能实现

% 思路：发送部分：初始随机信号，然后映射到QPSK，然后插入导频，然后合流发送（根升余弦滤波、载波调制？）
% 思路：接收部分：分流，导频信道估计、合流、信号均衡、匹配滤波、采样判决
% 关键：首先要知道现在自己在干什么(20250114)
% 第一级内容，第三级部分
% directed by STAssn

function main_MIMO()
    % directed by STAssn
    % 参数设定
    M_Tx = 2; % 双通道输入
    N_Rx = 2; % 双通道输出
    num_symbols = 14000; % 发送的符号数
    mod_QPSK = 4; % QPSK符号映射
    SNR = 40; % 信噪比dB
    pilot_num = 2; % 导频大小
    frame_num = 14; % 每帧数据长
    Fs = 16000; % 采样频率
    Fc = 2000; % 载波频率，应为每秒发送符号数的整数倍
    sign = 1000; % 每秒发送符号数
    
    % 发射机
    % 生成序列
    data_original = randi([0 1], num_symbols * 2, M_Tx);
    
    % QPSK符号映射
    QPSK_symbols = QPSK_mapping_B(data_original, num_symbols, M_Tx); % 符号映射到QPSK类型

    % 插入导频
    pilot = [1 / sqrt(2) + 1i / sqrt(2)  1 / sqrt(2) - 1i / sqrt(2); 1 / sqrt(2) - 1i / sqrt(2)  1 / sqrt(2) + 1i / sqrt(2)];
    tx_symbols = pilot_insert_2_channel(QPSK_symbols, pilot, M_Tx, pilot_num, frame_num);
    % plot(tx_symbols);

    % 脉冲成型与载波调制
    [tx_signal, ~, ~, i_tx, q_tx] = iq_carrier_modulation(tx_symbols, M_Tx, Fs, Fc, sign);

    % 发送波形
    % plot(tx_signal);

    % 信道中
    rx_signal = pass_random_channel(tx_signal, M_Tx, N_Rx, SNR);
    % rx_signal = tx_signal; % 测试用
    % plot(rx_signal);

    % 接收机
    % 载波解调与匹配滤波
    [rx_symbols, ~, ~] = iq_carrier_demodulation(rx_signal, Fs, Fc, sign, N_Rx);
    % plot(rx_symbols);
    
    % 信道估计与信号均衡
    pilot_symbol = pilot; % 双通道信道
    [H, handled_signal] = channel_estimate_and_balanced(rx_symbols, N_Rx, M_Tx, Fs, sign, pilot_num, frame_num, pilot_symbol);
    [H_2, ~, ~, judged_symbols_0, judged_symbols_1] = QPSK_channel_estimate_and_balanced_Beta(rx_symbols, N_Rx, M_Tx, Fs, sign, pilot_num, frame_num, pilot_symbol, SNR);
    [H_3, ~, ~, judged_symbols_2, judged_symbols_3] = QPSK_channel_estimate_and_balanced_MMSE(rx_symbols, N_Rx, M_Tx, Fs, sign, pilot_num, frame_num, pilot_symbol, SNR);
    [H_4, ~, ~, judged_symbols_4, judged_symbols_5] = QPSK_channel_estimate_and_balanced_LMMSE(rx_symbols, N_Rx, M_Tx, Fs, sign, pilot_num, frame_num, pilot_symbol, SNR);

    % QPSK基带解调
    bit_rx_1 = QPSK_demapping_B(handled_signal, N_Rx);   % LS_ZF_afterJudge
    bit_rx_2 = QPSK_demapping_B(judged_symbols_0, N_Rx); % LS_ZF
    bit_rx_3 = QPSK_demapping_B(judged_symbols_1, N_Rx); % LS_MMSE
    bit_rx_4 = QPSK_demapping_B(judged_symbols_2, N_Rx); % MMSE_ZF
    bit_rx_5 = QPSK_demapping_B(judged_symbols_3, N_Rx); % MMSE_MMSE
    bit_rx_6 = QPSK_demapping_B(judged_symbols_4, N_Rx); % LMMSE_MMSE
    bit_rx_7 = QPSK_demapping_B(judged_symbols_5, N_Rx); % LMMSE_MMSE

    % 调试结果，暂时占用，看误码率
    disp("Error Rate:");
    N_size = length(data_original);
    err = 0;
    for j = 1:M_Tx
        for i = 1:N_size
            if data_original(i, j) ~= bit_rx_1(i, j)
                err = err + 1;
            end
        end
    end
    err_rate = err / (N_size * M_Tx);
    disp("LS_ZF_afterJudge:");
    disp(err_rate); % 采样判决后进行信道估计算法结束后的误码率

    err_2 = 0;
    for j = 1:M_Tx
        for i = 1:N_size
            if data_original(i, j) ~= bit_rx_2(i, j)
                err_2 = err_2 + 1;
            end
        end
    end
    err_rate = err_2 / (N_size * M_Tx);
    disp("LS_ZF:");
    disp(err_rate); % 采样判决后进行信道估计算法结束后的误码率

    err_3 = 0;
    for j = 1:M_Tx
        for i = 1:N_size
            if data_original(i, j) ~= bit_rx_3(i, j)
                err_3 = err_3 + 1;
            end
        end
    end
    err_rate = err_3 / (N_size * M_Tx);
    disp("LS_MMSE:");
    disp(err_rate); % 采样判决后进行信道估计算法结束后的误码率

    err_4 = 0;
    for j = 1:M_Tx
        for i = 1:N_size
            if data_original(i, j) ~= bit_rx_4(i, j)
                err_4 = err_4 + 1;
            end
        end
    end
    err_rate = err_4 / (N_size * M_Tx);
    disp("MMSE_ZF:");
    disp(err_rate); % 采样判决后进行信道估计算法结束后的误码率

    err_5 = 0;
    for j = 1:M_Tx
        for i = 1:N_size
            if data_original(i, j) ~= bit_rx_5(i, j)
                err_5 = err_5 + 1;
            end
        end
    end
    err_rate = err_5 / (N_size * M_Tx);
    disp("MMSE_MMSE:");
    disp(err_rate); % 采样判决后进行信道估计算法结束后的误码率

    err_6 = 0;
    for j = 1:M_Tx
        for i = 1:N_size
            if data_original(i, j) ~= bit_rx_6(i, j)
                err_6 = err_6 + 1;
            end
        end
    end
    err_rate = err_6 / (N_size * M_Tx);
    disp("LMMSE_ZF:");
    disp(err_rate); % 采样判决后进行信道估计算法结束后的误码率

    err_7 = 0;
    for j = 1:M_Tx
        for i = 1:N_size
            if data_original(i, j) ~= bit_rx_7(i, j)
                err_7 = err_7 + 1;
            end
        end
    end
    err_rate = err_7 / (N_size * M_Tx);
    disp("LMMSE_MMSE:");
    disp(err_rate); % 采样判决后进行信道估计算法结束后的误码率


    % 临时总结：MMSE信道估计相对比较稳定，误码率能保持在较小水平；LS信道估计受噪声影响大，误码率波动严重。
    % 信号均衡目前看下来用MMSE还是ZF差异不大。
    % LMMSE不好说，前期误差太大死马当活马医找了一堆算法，同一算法不同说法公式一大堆都不一样，很多是变形公式，混乱.jpg
    
end