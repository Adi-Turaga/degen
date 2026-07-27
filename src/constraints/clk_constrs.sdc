# CLOCK-RELATED CONSTRAINTS
create_clock -name {clk_50MHz} -period 20.000 -waveform {0.000 10.000} [get_ports {clk}]
derive_clock_uncertainty