from Degen import Pulse, Bitmask

BAUD_RATE = 115200

p1 = {
    "t1": 0,
    "t2": 10e-6,
    "tX_sel": "tF",
    "F_clk": 50_000_000,
    "T_trig": 500
}

b1 = {
    "pulse_sel": "tAB",
    "bitmask": 0b100
}

# ===================================
# RANDOM TESTING BELOW
# ===================================

p = Pulse(p1)
p.encode_delays()
p.update_t1_del(5e-6)
p.update_t2_del(50e-6)
p.encode_delays()
#p.write('t1', 'COM5', BAUD_RATE)

b = Bitmask(b1)
b.encode_bitmask()
b.update_bitmask(0b011)

#b.write('COM5', BAUD_RATE)