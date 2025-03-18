function [handled_signal, handled_signal_MMSE] = signal_balanced(frame_num, frame, down_num, N, rx_signal, frame_all_num_signal, pilot_num, H, noise_power)
    % 迫零均衡
    handled_signal = zeros(frame_num * frame * down_num, N);
    signal_mid = zeros(frame_num * down_num, N); % 中间变量。单帧数据
    for i = 1:frame
        signal_mid(:, :) = rx_signal(((i - 1) * frame_all_num_signal + 1 + pilot_num * down_num):(i * frame_all_num_signal), :); % 脱离导频，只留下信号
        % H_this = H(:, :, i);
        % pseudo_inverse_matrix = pinv(H_this);
        % handled_signal(((i - 1) * frame_num * down_num + 1):(i * frame_num * down_num), :) = (pseudo_inverse_matrix * signal_mid')'; % 迫零均衡（？）
        H_this = H(:, :, i)'; % 和上面一样的，换种说法而已
        pseudo_inverse_matrix = pinv(H_this);
        handled_signal(((i - 1) * frame_num * down_num + 1):(i * frame_num * down_num), :) = (signal_mid * pseudo_inverse_matrix);
    end

    % MMSE均衡
    handled_signal_MMSE = zeros(frame_num * frame * down_num, N);
    signal_mid = zeros(frame_num * down_num, N); % 中间变量。单帧数据
    for i = 1:frame
        signal_mid(:, :) = rx_signal(((i - 1) * frame_all_num_signal + 1 + pilot_num * down_num):(i * frame_all_num_signal), :); % 脱离导频，只留下信号
        I = eye(size(H(:, :, i)' * H(:, :, i)));
        G = ((H(:, :, i)' * H(:, :, i) + noise_power * I) \ H(:, :, i)')';
        handled_signal_MMSE(((i - 1) * frame_num * down_num + 1):(i * frame_num * down_num), :) = signal_mid * G; % MMSE均衡（？）
    end
end