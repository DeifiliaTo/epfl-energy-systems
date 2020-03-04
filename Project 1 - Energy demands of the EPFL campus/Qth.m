function Q = Qth(deltaT, Ath, kth, T_int, T_ext, k_sun, ith, q_people, Q_el, heat_switch)
%Qth calculate heat load (eq. 1.3)
% Calculation multiplies the time interval by the energy required, and
% energy provided by irradiation, electrical, and by people

    % Only perform calculation if the exterior temperature is < 16 degrees
    % and we're in the heating periods
    if T_ext < 16 && heat_switch == 1
        Q = deltaT * ( Ath * ( kth * ( T_int-T_ext ) - k_sun * ith - q_people ) - Q_el);
    else
        Q = 0;
end