def generate_pulses(F_clk: int, T_trig: int, num_pulses: int):
    T_clk = 1 / F_clk   # FPGA clk period

fpga_clk_freq = 50e6
fpga_clk_period = 1 / fpga_clk_freq

trig_period = 400e-3

t1_delay = 0
t2_delay = 10e-6

t1AB_delay = 20e-6
t2AB_delay = 50e-6

pw = t2_delay - t1_delay

t1 = int(t1_delay / fpga_clk_period)
t2 = int(t1 + (pw / fpga_clk_period))

t1AB = int(t1AB_delay / fpga_clk_period)
t2AB = int(t2AB_delay / fpga_clk_period)

tA = (0b0000 << 20) | t1AB
tB = (0b0010 << 20) | t2AB
tC = (0b0100 << 20) | t1
tD = (0b0110 << 20) | t2
tE = (0b1000 << 20) | t1
tF = (0b1010 << 20) | t2

bitmask_AB = (0b0011 << 20) | 0b100
bitmask_CD = (0b0101 << 20) | 0b010
bitmask_EF = (0b1001 << 20) | 0b001

num2str = lambda num: f"24'h{str(hex(num))[2:]};"

print(f"tA_sel <= {num2str(tA)}\ntB_sel <= {num2str(tB)}\n\
tC_sel <= {num2str(tC)}\ntD_sel <= {num2str(tD)}\n\
tE_sel <= {num2str(tE)}\ntF_sel <= {num2str(tF)}")

print(f"bitmask_AB <= {num2str(bitmask_AB)}\n\
bitmask_CD <= {num2str(bitmask_CD)}\n\
bitmask_EF <= {num2str(bitmask_EF)}")