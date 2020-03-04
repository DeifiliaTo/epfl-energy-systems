% Calculation of Q+ over all the time intervals
% Eqn (1.4):
% If Q_th >= 0, add Qth(t) to sum. Otherwise, add 0

function q_year = q_plus_year (deltaT, Ath, kth, T_int, T_ext, k_sun, ith, q_people, Q_el_year, heat_switch)
    q_year = 0;
    for (i = 1:length(T_ext))
        Q_val = Qth(deltaT, Ath, kth, T_int, T_ext(i), k_sun, ith(i), q_people(i), Q_el_year(i), heat_switch(i));
        if (Q_val >= 0)
            q_ts = Q_val;
        else
            q_ts = 0;
        end
        q_year = q_year + q_ts;
    end 
end
