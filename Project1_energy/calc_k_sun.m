function [ksun, residual] = calc_k_sun (Ath, kth, Tint, Tcut, Irr_mean, q_mean, f_el, Q_el_mean)

ksun = (f_el*Q_el_mean/Ath + q_mean - kth*(Tint-Tcut))/(-1*Irr_mean);
residual = Ath * (kth*(Tint - Tcut)-ksun*Irr_mean - q_mean) - f_el * Q_el_mean;

end