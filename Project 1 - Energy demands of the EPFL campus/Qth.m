
function q = Qth(deltaT, Ath, kth, T_int, T_ext, k_sun, ith, q, f_el, Q_el)
    q = deltaT*(Ath*(kth*(T_int-T_ext)-k_sun*ith-q)-f_el*Q_el)
end
