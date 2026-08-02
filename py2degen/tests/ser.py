import serial
import time

ser = serial.Serial("COM5", 115200, timeout=1)
time.sleep(2)

d = 0b1010_0000_0000_0000_0000_0000
packet = d.to_bytes(3, byteorder='big')
ser.write(packet)
ser.close()

'''
response = ser.readline().decode().strip()
print(response)

ser.close()
'''