# If you add an instrument, add the variable name in this list
# in order to make input_adapter consider it.
# This file must be loaded last because the variables must be already loaded.
# The files in this directory are loaded in alphabetic order, so the
# filename zz_instruments_lists assures that it is loaded last (given
# no other instrument's filename starts with zz)

var instrumentsProps = {
	parents: [ # the order does not matter as long as the priority values differ 

# these are implemented in src/instrumentation/xxx.cxx or .hxx
		instr_radio_comm_generic, 
		instr_radio_nav_generic,
		instr_radio_adf_generic,
		instr_radio_dme_generic,
		instr_radio_transponder_generic,
		instr_ap_generic,
		instr_hdg_ind_generic,

# cessna 172p		
		instr_radio_kx165a,
		instr_radio_adf_kr87,
		instr_radio_dme_ki266,
		instr_ap_kap140,
		
# boeing 777
		instr_radio_rmu,
		instr_radio_transponder_boeing777,
		instr_ap_afds
		] 
};

var intrumentFunctions = ["radio_comm", "radio_nav", "radio_adf", "radio_dme", "radio_transponder", "ap", "hdg_ind"];

print("22222222222222222222222222222222222222: instrumentsProps:");
# debug.dump(instrumentsProps);
