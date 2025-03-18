% 上采样扩展数组，从符号到信号
function signal_up = to_up_sample(signal, num_to_up, M)
    % 上采样：输入信号（列向量）、上采样大小、通道数
    % directed by STAssn
    % 行向量包成功的，列向量就不行了，所以我决定先转置再按行向量处理再转置回来
    % signal_t = signal'; % 列向量转置成行向量
    % mid_signal = repmat(signal_t, num_to_up, 1); % 扩展
    % signal_up_t = reshape(mid_signal, M, []); % 行压缩（目前看起来规律是按列把每列下面的内容插在对应列元素的右边，列压缩也是按列插入所以不行）
    % signal_up = signal_up_t';

    % 上面的都有问题，应该采样成样值信号
    N_len = length(signal(:, 1));
    signal_mid = zeros(N_len * num_to_up, M);
    for i = 1:M
        signal_mid(:, i) = upsample(signal(:, i), num_to_up); % 上采样，多的补零
    end
    signal_up = signal_mid;
    for i = 1:N_len
        signal_up((i - 1) * num_to_up + floor(num_to_up / 2), :) = signal_mid((i - 1) * num_to_up + 1, :);
        signal_up((i - 1) * num_to_up + 1, :) = signal_mid((i - 1) * num_to_up + floor(num_to_up / 2), :); % 把数值移到中间去
    end
end