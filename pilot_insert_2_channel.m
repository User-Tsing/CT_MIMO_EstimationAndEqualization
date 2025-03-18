% 插入导频的操作
function [symbols_with_pilot] = pilot_insert_2_channel(input_symbols, pilot_signal, M, pilot_len, frame_length)
    % 输入信号（列向量）、导频信号（列向量或均可）、通道数、导频长度、帧长，输入信号长度应为帧长的倍数
    % directed by STAssn
    frame_num = ceil(length(input_symbols) / frame_length); % 帧数
    mid_symbols = zeros(pilot_len + frame_length, M, frame_num); % 三维数组，大小如左
    for i = 1:M
        for j = 1:frame_num
            if j ~= frame_num
                mid_symbols(1:pilot_len, i, j) = pilot_signal(:, i); % 插入导频
                mid_symbols(pilot_len + 1:end, i, j) = input_symbols((j - 1) * frame_length + 1:j * frame_length, i); % 原信号分帧
            else
                mid_symbols(1:pilot_len, i, j) = pilot_signal(:, i); % 插入导频
                len = length(input_symbols) - ((j - 1) * frame_length);
                mid_symbols(pilot_len + 1:pilot_len + len, i, j) = input_symbols((j - 1) * frame_length + 1:(j - 1) * frame_length + len, i); % 原信号分帧
                for k = pilot_len + len:pilot_len + frame_length
                    mid_symbols(k, i, j) = - 1 / sqrt(2) - 1i / sqrt(2); % 补零：赋值00
                end
            end
        end
    end
    symbols_with_pilot = reshape(permute(mid_symbols, [1, 3, 2]), [], M); % 合流，应该正确
end