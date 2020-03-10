
xlabel("Week number")
ylabel('Heat gain [kJ]')
title("Heat gain in buildings due to electrical applicances, yearly")
saveas(plot_q_el_year, "plots/el_year.png")

% Plots for Irr
plot_q_irr_day = bar(Irr*3.6)
xlabel("Hour")
ylabel('Heat gain [kJ/m2]')
title("Heat gain in buildings due to irradiation, hourly")
saveas(plot_q_irr_day, "plots/irr_hour.png")

plot_q_irr_week = bar(weekdays, q_irr_week*3.6)
xlabel("Day")
ylabel('Heat gain [kJ/m2]')
title("Heat gain in buildings due to irradiation, weekly")
saveas(plot_q_irr_week, "plots/irr_week.png")

plot_q_irr_year = bar(q_irr_year*3.6)
xlabel("Week number")
ylabel('Heat gain [kJ/m2]')
title("Heat gain in buildings due to irradiation, yearly")
saveas(plot_q_irr_year, "plots/irr_year.png")