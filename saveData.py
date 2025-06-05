import serial
import csv

ser = serial.Serial('COM4', 9600)  # Replace COM4 with your Arduino port
with open('distance_data.csv', 'w', newline='') as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(['Timestamp(ms)', 'Distance(cm)'])  # Header
    try:
        while True:
            line = ser.readline().decode().strip()
            if line:
                parts = line.split(',')
                if len(parts) == 2:
                    writer.writerow(parts)
                    csvfile.flush()
    except KeyboardInterrupt:
        pass
ser.close()
