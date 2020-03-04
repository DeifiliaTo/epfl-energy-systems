% Calculation of Q+ over all the time intervals
% Eqn (1.4):
% If Q_th >= 0, add Qth(t) to sum. Otherwise, add 0

function q_year = q_plus_year (deltaT, Ath, kth, T_int, T_ext, k_sun, ith, q_people, f_el, Q_el_year)
    q_year = 0;
    for (i = 1:length(T_ext))
        Q_val = Qth(deltaT, Ath, kth, T_int, T_ext, k_sun, ith, q_people, f_el, Q_el_year, i);
        if (Q_val >= 0)
            q_ts = Q_val;
        else
            q_ts = 0;
        end
        q_year = q_year + q_ts;
    end 
end
