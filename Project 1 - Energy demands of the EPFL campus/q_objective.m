
function q_diff = q_objective (deltaT, Ath, kth, T_int, T_ext, k_sun, ith, q, f_el, Q_el, Q_th)
    q_diff = q_plus_year(deltaT, Ath, kth, T_int, T_ext, k_sun, ith, q, f_el, Q_el) - Q_th;
end

