function q = Qth(deltaT, Ath, kth, T_int, T_ext, k_sun, ith, Q_gain, f_el, Q_el, index)
    % TODO: Check Q_gain, remove index here.
    index = 1;
    q = deltaT*(Ath*(kth*(T_int-T_ext(index))-k_sun*ith(index)-Q_gain(index))-f_el*Q_el);
end