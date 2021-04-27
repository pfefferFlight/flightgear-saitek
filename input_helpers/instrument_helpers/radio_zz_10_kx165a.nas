# This file contains data allowing an input device to
# access the kx165a navigation and communication radio 
# that is installed in the Cessna 172 in a standard way.
# It is processed by input_adapter.nas

var instr_radio_kx165a = {
	"radio/kx165a": { 
		parents: [instr_radio_comm_generic["radio_comm/generic"], 
		          instr_radio_nav_generic["radio_nav/generic"]],
		existenceTester: func(num=0) {return ( typeof(getprop("/instrumentation/comm[" ~ num ~ "]/frequencies/dial-khz")) != "nil" ); },
		functions: {"radio_comm": 10, "radio_nav": 10}, # number is the priority: if several instruments that provide the same functions seem to be installed in the aircraft (by existenceTester), the higher priority decides which one will be used
		actions: {
			"radio_comm/btn_swap": {
				aniProp: func(num = 0) { return "/instrumentation/comm[" ~ num ~ "]/frq-swap-btn"}
			},
			"radio_comm/freq_standby_btn_adjust_small": {
				aniProp: func(num) { return "/instrumentation/comm[" ~ num ~ "]/frequencies/dial-khz";}, 
				aniStep:  4
			},
			"radio_comm/freq_standby_btn_adjust_large": {
				aniProp: func(num) { return "/instrumentation/comm[" ~ num ~ "]/frequencies/dial-mhz";}, 
				aniStep:  4
			},
			"radio_nav/freq_active": {
				aniProp: func(num = 0) { return "/instrumentation/nav[" ~ num ~ "]/frq-swap-btn"} 			
			},
			"radio_nav/freq_standby_btn_adjust_small": {
				aniProp: func(num) { return "/instrumentation/nav[" ~ num ~ "]/frequencies/dial-khz";}, 
				aniStep:  4
			},
			"radio_nav/freq_standby_btn_adjust_large": {
				aniProp: func(num) { return "/instrumentation/nav[" ~ num ~ "]/frequencies/dial-mhz";}, 
				aniStep:  4
			}
		}
	}
};
