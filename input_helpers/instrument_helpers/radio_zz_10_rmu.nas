# This file contains data allowing an input device to
# access the Radio management unit (RMU), e.g. communication radio 
# that is installed in the Boeing 777 in a standard way.
# It is processed by input_adapter.nas

var instr_radio_rmu = { # in boeing 777
	"radio/rmu": { 
		parents: [instr_radio_comm_generic["radio_comm/generic"]],
		existenceTester: func(num=0) {return ( getprop("/instrumentation/rmu/unit[" ~ num ~ "]/hf-l") != nil ); }, # actually I prefer testing for the needed property but in this case this is not effective because "/instrumentation/rmu/unit[" ~ num ~ "]/selected-mhz" gets saved and loaded, even if an aircraft is used that does not have an rmu. So we use a property that the rmu inititializes but is not saved
		functions: {"radio_comm": 10}, # number is the priority: if several instruments that provide the same functions seem to be installed in the aircraft (by existenceTester), the higher priority decides which one will be used
		displays: {                                                                          #parents[0].displays["radio_comm/freq_active"].propGetter(num)
			"radio_comm/freq_active":    {watcher: func(num = 0) {var internalfreq = getprop("/instrumentation/comm[" ~ num ~ "]/frequencies/selected-mhz"); setprop("/instrumentation/rmu/unit[" ~ num ~ "]/selected-mhz", internalfreq);} },
			"radio_comm/freq_standby":   {watcher: func(num = 0) {var internalfreq = getprop("/instrumentation/comm[" ~ num ~ "]/frequencies/standby-mhz");  setprop("/instrumentation/rmu/unit[" ~ num ~ "]/standby-mhz", internalfreq);} },

		}
	}
};