import serial
import time

BAUD_RATE = 115200

class Pulse:
    tX_values = {
        "tA": 0b0000, "tB": 0b0010,
        "tC": 0b0100, "tD": 0b0110,
        "tE": 0b1000, "tF": 0b1010
    }

    def __init__(self, t_info: dict):
        self.t1_del = t_info["t1"]  # t1 delay value (how long after trigger t1 is activated)
        self.t2_del = t_info["t2"]  # t2 delay value (same logic as t1)
        self.tX_sel = t_info["tX_sel"]  # which tX (tA, tB, ..., tF)
        self.F_clk = t_info["F_clk"]    # FPGA clk frequency (50 MHz, 100 MHz, etc.)
        self.T_trig = t_info["T_trig"]  # period of trigger, in scientific notation (e.g. 500e-6)

    def tX_assigned(self):
        return self.tX_values[self.tX_sel]  # reads the dictionary above

    def update_t1_del(self, new_t1_del: int): self.t1_del = new_t1_del
    def update_t2_del(self, new_t2_del: int): self.t2_del = new_t2_del

    def encode_delays(self):
        assert self.t1_del < self.t2_del, "[ERROR]: t1 value cannot be larger than t2 value" 

        T_clk = 1/self.F_clk    # convert the frequency to period for easier calculations

        pw = self.t2_del - self.t1_del  # calculates pulse width
        t1_raw = int(self.t1_del / T_clk)
        t2_raw = int(self.t1_del + (pw / T_clk))
        print(f"t1_raw: {t1_raw}\nt2_raw: {t2_raw}")

        # encodes metadata in first 4 bits -> ORed with delay info in lower bits
        self.t1 = (self.tX_assigned() << 20) | t1_raw
        self.t2 = (self.tX_assigned() << 20) | t2_raw
        print(f"t1: {self.t1:024b}/{hex(self.t1)}\nt2: {self.t2:024b}/{hex(self.t2)}")

    def convert2bytes(self):
        self.t1b = self.t1.to_bytes(3, byteorder="big")
        self.t2b = self.t2.to_bytes(3, byteorder="big")

    def write(self, tX_sel: str, serial_port: str, baud_rate: int):
        degen = serial.Serial(serial_port, baud_rate, timeout=1)
        time.sleep(2)
        delay_sel = self.t1b if tX_sel == "t1" else self.t2b
        print(delay_sel)
        degen.write(delay_sel)
        degen.close()

    def write_both(self, serial_port: str, baud_rate: int):
        self.write("t1", serial_port, baud_rate)
        self.write("t2", serial_port, baud_rate)


class Bitmask:
    tX_values = {
        "tAB": 0b0010, "tCD": 0b0100, "tEF": 0b1000
    }
        
    def __init__(self, b_info: dict):
        self.bitmask = b_info["bitmask"]    # bitmask pattern
        self.tX_sel = b_info["pulse_sel"]   # the selection of the necessary pulse

    def tX_assigned(self):
        return (self.tX_values[self.tX_sel] | 0b001)   # ORed with 0b0001 to set is_bitmask=1

    def encode_bitmask(self):
        # encodes metadata in first 4 bits -> ORed with delay info in lower bits
        return (self.tX_assigned() << 20) | self.bitmask

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

p = Pulse(p1)
p.encode_delays()
p.convert2bytes()
print(p.t2b)
p.write_both('COM5', BAUD_RATE)

b = Bitmask(b1)
print(f"{b.encode_bitmask():024b}")