% QPSK基带解调
function [bit_stream] = QPSK_demapping_B(symbols, N)
    % QPSK基带解调
    % directed by STAssn
    len = length(symbols);
    bit_stream = zeros(len * 2, N);
    for j = 1:N
        for i = 1:len
            real_sym = real(symbols(i, j));
            imag_sym = imag(symbols(i, j));
            if real_sym >= 0
                bit_stream(2 * i - 1, j) = 1;
            else
                bit_stream(2 * i - 1, j) = 0;
            end
            if imag_sym >= 0
                bit_stream(2 * i, j) = 1;
            else
                bit_stream(2 * i, j) = 0;
            end
        end
    end
end