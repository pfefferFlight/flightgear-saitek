# This file contains data allowing an input device to
# access in a standard way the generic heading indicator.
# It is processed by input_adapter.nas

var instr_hdg_ind_generic = { # defined in Aircraft/Instruments/hdg.xml # present in cessna 172
	"hdg_ind/generic": {
		parents: [],
		existenceTester: func(num=0) {return ( getprop("/autopilot/settings/heading-bug-deg") != nil ); }, # better use return input_helpers.propPathExists() ?
		functions: {"hdg_ind": 0}, # number is the priority: if several instruments that provide the same functions seem to be installed in the aircraft (by existenceTester), the higher priority decides which one will be used
		actions: {
			"hdg_ind/hdg_bug_btn_up":  {btnType: "biased", press: func() {var cHdg = getprop("/autopilot/settings/heading-bug-deg"); if (cHdg == nil) {cHdg = 0;} setprop("/autopilot/settings/heading-bug-deg",  ( (cHdg+1) < 360 ) ? (cHdg+1) : (cHdg+1-360) );   return 1;}, release: func() {} },
			"hdg_ind/hdg_bug_btn_down":{btnType: "biased", press: func() {var cHdg = getprop("/autopilot/settings/heading-bug-deg"); if (cHdg == nil) {cHdg = 0;} setprop("/autopilot/settings/heading-bug-deg",  ( (cHdg-1) >= 0  ) ? (cHdg-1) : (cHdg-1+360) );   return 1;}, release: func() {} }
		# Todo: add actions for: adjusting north to magnetic north (as this is an vacuum spin indicator)
		}
	}
};
