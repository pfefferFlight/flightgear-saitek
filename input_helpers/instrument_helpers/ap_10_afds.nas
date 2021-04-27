# This file contains data allowing an input device to
# access in a standard way the autopilot AFDS 
# (Automatic Flight and Director System) in the Boeing 777
# It is processed by input_adapter.nas
# Note: At the moment, most push buttons work only on  the 777
# (because b777.afds.xxxx is used)
# whereas the display and adjustments are expected to work 
# also in other aircrafts.

var instr_ap_afds = { # "Auto Flight Director Systems" = autopilot in boeing 777
	"ap/led_ap": { # see Aitcraft/777/Nasal/AFDS.nas
		# Roll modes /instrumentation/afds/ap-modes/roll-mode
		#	TO/GA or ROLLOUT = keep wings level
		#   HDG HOLD (2) or HDG SEL (1) = stear to a given heading 
		#   LOC = stear to a given radial on a VOR(resp. ILS?)
		#   TRK SEL, TRK HOLD = ? hold true heading (taking cross wind into account)
		# Pitch modes /instrumentation/afds/ap-modes/pitch-mode
		# 	V/S = vertical speed hold
		# lateral buttons (mode = 0):
		# 	0: ?
		# 	1 HDG SEL
		# 	2 HDG HOLD
		# 	3 LNAV
		# vertical buttons (mode = 1)
		# 	1: hold current alt
		# 	2: hold current vertical speed
		# 	4: Altutude intervention
		# 	255: ?
		# 	5: VNAV
		# 	8: FLCH SPD (Flightlevel change speed)
		# Throttle buttons (mode = 2)
		# 	2: TOGA (Take-Off / Go Around)
		# FD, LOC or G/S button (mode==3)
		#	0: ?
		#	1: Approach button
		#	2: Filght director button
		#	3: AP button toggle
		# HDG REF button, TRK-HDG (mode = 4)
		# 	0: Heading or Tracking HDG REF TRK-HDG
		
		parents: [instr_ap_generic["ap/generic"]],
		existenceTester: func(num=0) {return ( getprop("/instrumentation/afds/inputs/AP") != nil ); }, 
		functions: {"ap": 10}, # number is the priority: if several instruments that provide the same functions seem to be installed in the aircraft (by existenceTester), the higher priority decides which one will be used
		displays: {
			# flags/leds
			"ap/led_ap" :       ["/instrumentation/afds/inputs/AP"],
			"ap/led_hdg":       {propGetter: func() {return ["/instrumentation/afds/ap-modes/roll-mode" ]; }, getValue: func() { var rollmode = getprop("/instrumentation/afds/ap-modes/roll-mode");return ( (rollmode == "HDG HOLD") or (rollmode == "HDG SEL")); } }, # see 777-autopilot.xml
			"ap/led_nav":       {propGetter: func() {return ["/instrumentation/afds/ap-modes/roll-mode" , "/instrumentation/afds/ap-modes/roll-mode-arm" ]; }, getValue: func() { var rollmode  = getprop("/instrumentation/afds/ap-modes/roll-mode" );return ( (rollmode  == "LNAV") or  (getprop("/instrumentation/afds/ap-modes/roll-mode-arm") == "LNAV") ); } }, # see Models/ap-panel.xml and 777-autopilot.xml
			"ap/led_ias":       ["/instrumentation/afds/inputs/ias-mach-selected"],
			"ap/led_alt":       {propGetter: func() {return ["/instrumentation/afds/ap-modes/pitch-mode", "/instrumentation/afds/ap-modes/speed-mode"];     }, getValue: func() { var pitchmode = getprop("/instrumentation/afds/ap-modes/pitch-mode");return ( (pitchmode == "ALT" ) and (getprop("/instrumentation/afds/ap-modes/speed-mode"   ) != ""    ) ); } }, # see Models/ap-panel.xml and 777-autopilot.xml
			"ap/led_vs" :       {propGetter: func() {return ["/instrumentation/afds/ap-modes/pitch-mode"];     }, getValue: func() { var pitchmode = getprop("/instrumentation/afds/ap-modes/pitch-mode");return ( (pitchmode == "V/S" ) or  (pitchmode == "FPA") ); } }, # see Models/ap-panel.xml and 777-autopilot.xml
			"ap/led_apr":       {propGetter: func() {return ["/instrumentation/afds/ap-modes/pitch-mode", "/instrumentation/afds/inputs/gs-armed"];         }, getValue: func() { var pitchmode = getprop("/instrumentation/afds/ap-modes/pitch-mode");return ( (pitchmode == "G/S" ) or  (getprop("/instrumentation/afds/inputs/gs-armed"       ) != 0     ) ); } }, # see Models/ap-panel.xml and 777-autopilot.xml
			"ap/led_flch":      {propGetter: func() {return ["/instrumentation/afds/ap-modes/pitch-mode"];         }, getValue: func() { var pitchmode = getprop("/instrumentation/afds/ap-modes/pitch-mode");return ( (pitchmode == "FLCH SPD" ) or  (getprop("/instrumentation/afds/inputs/gs-armed"       ) != 0     ) ); } }, # see Models/ap-panel.xml and 777-autopilot.xml
# 		
			# numbers
			"ap/target_alt_ft" :    {propGetter: func() {return ["/autopilot/settings/counter-set-altitude-ft"];}, formatGetter: func(num) {return "R%5i";} },
			"ap/target_ias":        {
				propGetter: func() {
					if (getprop("/instrumentation/afds/inputs/ias-mach-selected") ) { return ["/autopilot/settings/target-speed-mach", "/instrumentation/afds/inputs/ias-mach-selected"]; }
					else                                                            { return ["/autopilot/settings/target-speed-kt",   "/instrumentation/afds/inputs/ias-mach-selected"];}
				}, 
				formatGetter: func(num) {
					if (getprop("/instrumentation/afds/inputs/ias-mach-selected") ) { return "R%4.3f"; } # display mach
					else                                                            { return "R%4u";   } # display knots
				}
			},
			"ap/target_vs_fpm" :    {
				propGetter:   func()    {return ["instrumentation/afds/ap-modes/pitch-mode", "/autopilot/settings/vertical-speed-fpm"];},
				getValue:     func()    {if (getprop("instrumentation/afds/ap-modes/pitch-mode") == "V/S") {return getprop("/autopilot/settings/vertical-speed-fpm");} else {return nil;} }, # V/S display is blank if not in V/S mode
				formatGetter: func(num) {return "R%5i";}
			}
		},
		actions: { # instrumentation/afds/inputs/ias-mach-selected 
			# Toggle buttons
			"ap/btn_throttle": {
				btnType: "toggle", 
				press:   func() {setprop("/instrumentation/afds/inputs/at-armed", 1); setprop("/instrumentation/afds/inputs/at-armed[1]", 1);return 1;}, 
				release: func() {setprop("/instrumentation/afds/inputs/at-armed", 0); setprop("/instrumentation/afds/inputs/at-armed[1]", 0);return 1;} 
			},
			
			# Push-buttons
			"ap/btn_on_off": { btnType: "biased", press: func() {propertyToggle("/instrumentation/afds/inputs/AP"); return 1;}, release: func() {return 1;} },
			# lateral
			"ap/btn_hdg_trk":    { btnType: "biased", press: func() {propertyToggle("/instrumentation/efis/hdg-trk-selected"); return 1;}, release: func() {return 1;} }, # switch between track and heading 
			"ap/btn_hdg_sel":    { btnType: "biased", press: func() {b777.afds.input(0,1); return 1;}, release: func() {return 1;} }, # Select Heading (HDG SEL)
			"ap/btn_hdg_hold":   { btnType: "biased", press: func() {b777.afds.input(0,2); return 1;}, release: func() {return 1;} }, # Select Heading (HDG HOLD)
			"ap/btn_nav":        { btnType: "biased", press: func() {b777.afds.input(mode: 0, btn: 3);  return 1;}, release: func() {return 1;} }, #0: lateral btns, 3: LNAV btn
			# vertical
			"ap/btn_alt":    { btnType: "biased", press: func() {b777.afds.input(mode: 1, btn: 1);  return 1;}, release: func() {return 1;} },
			"ap/btn_vs":     { btnType: "biased", press: func() {b777.afds.input(mode: 1, btn: 2);  return 1;}, release: func() {return 1;} },
			"ap/btn_flch":   { btnType: "biased", press: func() {b777.afds.input(mode: 1, btn: 8);  return 1;}, release: func() {return 1;} }, # Flight level change
			# other
			"ap/btn_apr":    { btnType: "biased", press: func() {b777.afds.input(mode: 3, btn: 1);  return 1;}, release: func() {return 1;} }, # 3: LOC/GS btns, 1: APPR btn
			"ap/btn_ias":    { btnType: "biased", press: func(num) {propertyToggle("/instrumentation/afds/inputs/ias-mach-selected"   ); return 1;}, release: func() {return 1;} }, # change between mach and knots speed gauge

			# adjust numbers
			"ap/btn_ias_up":   {
				btnType: "biased", 
				press: func() {
					if (getprop("instrumentation/afds/inputs/ias-mach-selected")) {
						# mach  # Todo: check if it works
						setprop("/autopilot/settings/target-speed-mach", getprop("/autopilot/settings/target-speed-mach") + 0.001);
					} else {
						# knots
						setprop("/autopilot/settings/target-speed-kt", getprop("/autopilot/settings/target-speed-kt") + 1);  
					}
					return 1;
				}, release: func() {return 1;} 
			},
			"ap/btn_ias_down":   {
				btnType: "biased", 
				press: func() {
					if (getprop("instrumentation/afds/inputs/ias-mach-selected")) {
						# mach  # Todo: check if it works
						setprop("/autopilot/settings/target-speed-mach", getprop("/autopilot/settings/target-speed-mach") - 0.001);
					} else {
						# knots
						setprop("/autopilot/settings/target-speed-kt", getprop("/autopilot/settings/target-speed-kt") - 1);  
					}
					return 1;
				}, release: func() {return 1;} 
			},
			"ap/btn_alt-up":     { btnType: "biased", press: func() { setprop("/autopilot/settings/counter-set-altitude-ft", getprop("/autopilot/settings/counter-set-altitude-ft") + 100);	return 1;}, release: func() {return 1;} },
			"ap/btn_alt-down":   { btnType: "biased", press: func() { setprop("/autopilot/settings/counter-set-altitude-ft", getprop("/autopilot/settings/counter-set-altitude-ft") - 100);	return 1;}, release: func() {return 1;} }
		}
	}
};
