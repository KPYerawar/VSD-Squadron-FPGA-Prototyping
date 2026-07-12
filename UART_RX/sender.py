"""
uart_sender.py
Sends '0','1','2','3' (ASCII 0x30-0x33) over UART every 3 seconds,
cycling through them. Lower 2 bits of each ASCII code = 00,01,10,11.

Install pyserial first:
    pip install pyserial
"""

import serial
import time

PORT = "/dev/ttyUSB1"      # Windows: "COM5" etc. | Linux: "/dev/ttyUSB0"
BAUD = 9600
DELAY_SEC = 3

codes = ['0', '1', '2', '3']   # binary 00, 01, 10, 11 respectively

def main():
    ser = serial.Serial(PORT, BAUD, timeout=1)
    time.sleep(2)  # let CH340 enumerate / settle before first write

    print(f"Opened {PORT} @ {BAUD} baud. Sending every {DELAY_SEC}s. Ctrl+C to stop.")

    idx = 0
    try:
        while True:
            code = codes[idx % len(codes)]
            ser.write(code.encode('ascii'))
            binary_val = format(ord(code) & 0x3, '02b')
            print(f"Sent '{code}'  -> binary code {binary_val}")
            idx += 1
            time.sleep(DELAY_SEC)
    except KeyboardInterrupt:
        print("\nStopped by user.")
    finally:
        ser.close()

if __name__ == "__main__":
    main()
