% Objective function that is to be minimized w/ NR method
% Eqn (1.5): Q+_th, year = sum over all buildings of (Q_th+)

function q_diff = q_objective (deltaT, Ath, kth, T_int, T_ext, k_sun, ith, q_people, f_el, Q_el_year, Q_th)
    q_diff = q_plus_year(deltaT, Ath, kth, T_int, T_ext, k_sun, ith, q_people, f_el, Q_el_year) - Q_th;
end
