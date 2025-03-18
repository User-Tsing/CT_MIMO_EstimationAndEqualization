% QPSK符号映射函数
function [output_signal] = QPSK_mapping_B(input_signal, num_symbols, M)
    % QPSK符号映射（发射机），采用B类吧应该是
    % 输入信号、信号长度、通道数
    % directed by STAssn
    I_signal = zeros(num_symbols, M); % I路
    Q_signal = zeros(num_symbols, M); % Q路
    for i = 1:M
        % mid_signal = reshape(input_signal(:, i), [], 2); % 逐通道重构
        % I_signal(:, i) = (2 * mid_signal(:, 1) - 1) / sqrt(2); % 拆分并更改为双极性
        % Q_signal(:, i) = (2 * mid_signal(:, 2) - 1) / sqrt(2);
        I_signal(:, i) = (2 * input_signal(1:2:end - 1, i) - 1) / sqrt(2);
        Q_signal(:, i) = (2 * input_signal(2:2:end, i) - 1) / sqrt(2);
    end
    output_signal = I_signal + 1i * Q_signal; % 符号映射完成
end