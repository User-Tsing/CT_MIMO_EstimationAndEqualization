% 采样判决
function [symbols, symbols_i, symbols_q] = sampling_and_judge_per_frame(signal, N, fs, sign_num)
    % 信号、通道数、采样频率、每秒符号数（符号频率）
    % directed by STAssn
    % 采样
    down_num = fs / sign_num; % 每个符号多少点
    signal_size = size(signal(:, N)); % 信号大小
    symbols_num = signal_size(1) / down_num; % 符号多少，矩阵大小有两个值，由于信号为列向量，这里取行数
    symbols_mid = zeros(symbols_num, N);
    for i = 1:N
        for j = 1:symbols_num
            symbols_mid(j, i) = signal((j - 1) * down_num + down_num / 2, i); % 直接取中间那个（状态存疑）
        end
    end

    % 判决
    symbols = zeros(symbols_num, N);
    symbols_i = zeros(symbols_num, N);
    symbols_q = zeros(symbols_num, N);
    for i = 1:N
        for j = 1:symbols_num
            if real(symbols_mid(j, i)) >= 0 && imag(symbols_mid(j, i)) >= 0
                symbols(j, i) = 1 / sqrt(2) + 1i / sqrt(2);
                symbols_i(j, i) = 1 / sqrt(2);
                symbols_q(j, i) = 1 / sqrt(2);
            elseif real(symbols_mid(j, i)) >= 0 && imag(symbols_mid(j, i)) <= 0
                symbols(j, i) = 1 / sqrt(2) - 1i / sqrt(2);
                symbols_i(j, i) = 1 / sqrt(2);
                symbols_q(j, i) = - 1 / sqrt(2);
            elseif real(symbols_mid(j, i)) <= 0 && imag(symbols_mid(j, i)) <= 0
                symbols(j, i) = - 1 / sqrt(2) - 1i / sqrt(2);
                symbols_i(j, i) = - 1 / sqrt(2);
                symbols_q(j, i) = - 1 / sqrt(2);
            elseif real(symbols_mid(j, i)) <= 0 && imag(symbols_mid(j, i)) >= 0
                symbols(j, i) = - 1 / sqrt(2) + 1i / sqrt(2);
                symbols_i(j, i) = - 1 / sqrt(2);
                symbols_q(j, i) = 1 / sqrt(2);
            end
        end
    end
end