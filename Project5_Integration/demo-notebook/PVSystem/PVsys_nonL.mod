
subject to pbt_cstr:
	obj_fcn['pbt'] = obj_fcn['totex']/(sum{t in Time} (p_load[t]*ts*t_imp[t]) - obj_fcn['opex']);
	
subject to sc_cstr:
	obj_fcn['SC'] = (sum{t in Time} p_sc[t])/(sum{t in Time} p_pv[t]);
subject to pv_cur_cstr:
	obj_fcn['pv_cur'] =  (sum{t in Time} p_cur[t])/(sum{t in Time} p_pv[t]);
