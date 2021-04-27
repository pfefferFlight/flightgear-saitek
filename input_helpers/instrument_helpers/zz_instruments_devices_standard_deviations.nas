# This files contains deviations from standard names from
# an input device if a certain instrument is installed in the aircraft.
# If you want a certain LED/button from a specific input device, 
# e.g. the IAS button from the Saitek Multi Panel, to map on a non-standard 
# button/annunciator/LED of a specific Instrument (e.g. on 
# the ALT-ARM button of the autopilot kap140), add this deviation in this list.
#
# (Note: The name of this file starts with "zz" just in order to have all
# files relevant to all instruments near to each other in the directory listing)

var nameDeviations = {
	"saitek-multi": {
		# Cessna 172p
		"ap/kap140": {
			# "LED/display/button in input device": "LED/annunciator/button of the instrument"
			"ap/led_ias":             "ap/led_alt-arm",
			"ap/btn_ias":             "ap/btn_alt-arm", # the kap140 does not provide auto throttle or target-ias, so we use it as alt-arm button
			"ap/btn_vs":              "ap/btn_baro", # the vs button does not exits in kap140, so we use it as baro button
			"ap/btn_vs_up":    func() { 
				# if the baro is shown, adjust the baro setting instead of vs or target alt
				if ( getprop("/autopilot/KAP140/annunciators/bs-inhg-number") or getprop("/autopilot/KAP140/annunciators/bs-hpa-number") ) {
					return "ap/btn_baro_up"; }
					else {
						# in KAP140 pressing the UP-Button increses alt in alt mode and increses vs in vs mode. 
						# Accordingly if "VS" is selected, turning the adjust button on the Saitek 
						# adjusts target vs or target alt, depending on the KAP140 mode.
						if ( getprop("/autopilot/KAP140/annunciators/alt") ) { return "ap/btn_alt-up"; }
						else                                                 { return "ap/btn_vs_up";  }
				}
			},
			"ap/btn_vs_down":    func() {
				# if the baro is shown, adjust the baro setting instead of vs or target alt
				if ( getprop("/autopilot/KAP140/annunciators/bs-inhg-number") or getprop("/autopilot/KAP140/annunciators/bs-hpa-number") ) {
					return "ap/btn_baro_down";
				} else {
					if ( getprop("/autopilot/KAP140/annunciators/alt") ) { return "ap/btn_alt-down"; }
					else                                                 { return "ap/btn_vs_down";  }
				}
			},
			"ap/btn_alt-up":   func() {
				# in KAP140 if the baro is shown, the knob adjusts the baro setting
				if ( getprop("/autopilot/KAP140/annunciators/bs-inhg-number") or getprop("/autopilot/KAP140/annunciators/bs-hpa-number") ) {
					return "ap/btn_baro_up";
				} else {
					return "ap/btn_alt-arm-up";
				}
			},
			"ap/btn_alt-down": func() {
				# in KAP140 if the baro is shown, the knob adjusts the baro setting
				if ( getprop("/autopilot/KAP140/annunciators/bs-inhg-number") or getprop("/autopilot/KAP140/annunciators/bs-hpa-number") ) {
					return "ap/btn_baro_down";
				} else {
					return "ap/btn_alt-arm-down";
				}
			},
			"ap/target_vs_fpm": "$ap/disp_lower_vs_fpm", # what shall be shown in the lower row on the saitek-multi-panel, depends on internal situation of the kap140 --> returning a name starting with "$" will cause input_adapter.watcher() to call the according getVaule()/formatGetter()/watcher() from this file instead of the original instrument
			"$ap/disp_lower_vs_fpm": {
				propGetter: func() {
					# print("ggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg");
					var p1 = instr_ap_kap140["ap/kap140"].displays["ap/target_vs_fpm"].propGetter();
					var p2 = instr_ap_kap140["ap/kap140"].displays["ap/baro"].propGetter();
					return p1 ~ p2;
				},
				getValue: func(num) {
					#print("ppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppp");
					if ( getprop("/autopilot/KAP140/annunciators/bs-inhg-number") or getprop("/autopilot/KAP140/annunciators/bs-hpa-number") ) {
						    return instr_ap_kap140["ap/kap140"].displays["ap/baro"].getValue(num) ; }
					else {	return instr_ap_kap140["ap/kap140"].displays["ap/target_vs_fpm"].getValue(num); }
				},
				formatGetter: func(num) {
					if ( getprop("/autopilot/KAP140/annunciators/bs-inhg-number") or getprop("/autopilot/KAP140/annunciators/bs-hpa-number") )
					{ 		return instr_ap_kap140["ap/kap140"].displays["ap/baro"].formatGetter(num); }
					else {	return instr_ap_kap140["ap/kap140"].displays["ap/target_vs_fpm"].formatGetter(num); }
				}
			}
		},
		# Boeing 777
		"ap/led_ap": {
			"ap/btn_hdg": "ap/btn_hdg_sel",
			"ap/btn_ias": "ap/btn_flch",
			"ap/led_ias": "ap/led_flch"
		}
	},
	"saitek-radio": {
		"radio_dme/ki266": {
			"radio_dme/time_min":  "radio_dme/min_kts", # ki266 supports switching between "time to DME" and "speed-kts" on the right display
			"radio_dme/speed_kts": "radio_dme/min_kts"  # ki266 supports switching between "time to DME" and "speed-kts" on the right display
		}
	}
};