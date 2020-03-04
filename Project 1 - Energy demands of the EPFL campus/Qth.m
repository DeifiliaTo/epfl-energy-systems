function q = Qth(deltaT, Ath, kth, T_int, T_ext, k_sun, ith, Q_gain, f_el, Q_el_year, index)
    if (T_ext(index) < 16)
        q = deltaT*(Ath*(kth*(T_int-T_ext(index))-k_sun*ith(index)-Q_gain(index))-Q_el_year(index));
    else
        q = 0;
end