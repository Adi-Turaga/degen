import serial
import time

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

    def calculate_raw_delay(self):
        """
            In the RTL, delays are represented by clock cycles (function of clock frequency)
            This function calculates when the pusle should be asserted respective to clock cycles

            e.g.: t1_raw=0 and t2_raw=500: t1 is asserted immidiately and t2 is asserted after 500 cycles
        """

        assert self.t1_del < self.t2_del, "[ERROR]: t1 value cannot be larger than t2 value" 

        T_clk = 1/self.F_clk    # convert the frequency to period for easier calculations

        pw = self.t2_del - self.t1_del  # calculates pulse width
        t1_raw = int(self.t1_del / T_clk)   # calculates how many cycles needed to start counter
        t2_raw = int(self.t1_del + (pw / T_clk))    # same logic as t1_raw
        print(f"@ {self.F_clk:_} Hz:")
        print('-------------------------')
        print(f"t1_raw: {t1_raw} cycles\nt2_raw: {t2_raw} cycles")

        return (t1_raw, t2_raw)

    def encode_delays(self):
        t1_raw, t2_raw = self.calculate_raw_delay()

        # encodes metadata in first 4 bits -> ORed with delay info in lower bits
        t1 = (self.tX_assigned() << 20) | t1_raw
        t2 = (self.tX_assigned() << 20) | t2_raw
        print("==================================================================")
        print(f"t1 (bin): {t1:024b}\t(hex): {hex(t1)}\nt2 (bin): {t2:024b}\t(hex): {hex(t2)}")
        print("==================================================================")
        return (t1, t2)

    def convert2bytes(self):
        t1, t2 = self.encode_delays()
        t1b = t1.to_bytes(3, byteorder="big")
        t2b = t2.to_bytes(3, byteorder="big")
        return t1b, t2b

    def write(self, tX_sel: str, serial_port: str, baud_rate: int):
        t1b, t2b = self.convert2bytes()
        ser = serial.Serial(serial_port, baud_rate, timeout=1)
        time.sleep(2)   # USED FOR ARDUINO TESTING
        delay_sel = t1b if tX_sel == "t1" else t2b
        ser.write(delay_sel)
        ser.flush()

    def write_both(self, serial_port: str, baud_rate: int):
        self.write("t1", serial_port, baud_rate)
        self.write("t2", serial_port, baud_rate)

class Bitmask:
    tX_values = {
        "tAB": 0b0010, "tCD": 0b0100, "tEF": 0b1000
    }
        
    def __init__(self, b_info: dict):
        self.bitmask = b_info["bitmask"]    # bitmask pattern
        self.tX_sel = b_info["pulse_sel"]   # selection of the necessary pulse

    def tX_assigned(self) -> int:
        return (self.tX_values[self.tX_sel] | 0b001)   # ORed with 0b0001 to set is_bitmask=1

    def update_bitmask(self, new_bitmask: int):
        self.bitmask = new_bitmask

    def encode_bitmask(self) -> int:
        # encodes metadata in first 4 bits -> ORed with delay info in lower bits
        bitmask_enc = (self.tX_assigned() << 20) | self.bitmask
        print(f"bm (bin): {bitmask_enc:024b}\t(hex): {hex(bitmask_enc)}")
        return bitmask_enc

    def convert2bytes(self):
        bitmask_enc = self.encode_bitmask()
        return bitmask_enc.to_bytes(3, byteorder='big')

    def write(self, serial_port: str, baud_rate: int):
        ser = serial.Serial(serial_port, baud_rate, timeout=1)
        time.sleep(2)   # USED FOR ARDUINO TESTING
        bitmask_b = self.convert2bytes()
        ser.write(bitmask_b)
        ser.flush()