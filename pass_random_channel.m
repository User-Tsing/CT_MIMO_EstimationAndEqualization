% 信号通过随机信道
function [rx_signal] = pass_random_channel(tx_signal, M, N, SNR_dB)
    % 随机信道由信道矩阵表示
    % directed by STAssn
    % H = (1 / sqrt(2)) * (randn(N, M) + 1i * randn(N, M)); % 复数信道传输矩阵，表示增益，[h11 h21; h12 h22]
    H = (1 / sqrt(2)) * randn(N, M); % 实数信道传输矩阵，表示增益，[h11 h21; h12 h22]
    % plot(tx_signal);
    rx_pure_signal = tx_signal * H; % 矩阵乘，由输入信号到无噪输出信号
    % plot(rx_pure_signal); % 看效果
    noise_power = 10 ^ (- SNR_dB / 10);
    noise_signal = sqrt(noise_power / 2) * (randn(size(rx_pure_signal))); % 设定：高斯白噪声（不复是因为载波信号纯实）
    rx_signal = rx_pure_signal + noise_signal; % 过信道加噪声处理
end