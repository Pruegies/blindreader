import RPi.GPIO as GPIO
from time import sleep
from picamera2 import Picamera2
from libcamera import controls
import os
from bluedot.btcomm import BluetoothServer
from signal import pause
import base64
from pylibdmtx.pylibdmtx import decode

GPIO.setmode(GPIO.BOARD)
ButtonPin = 10
BuzzerPin = 16
GPIO.setup(ButtonPin, GPIO.IN, pull_up_down=GPIO.PUD_UP)
GPIO.setup(BuzzerPin,GPIO.OUT, initial = 0)

picam2 = Picamera2()
picam2.start(show_preview=True)
picam2.set_controls({"AfMode": controls.AfModeEnum.Continuous, "AfSpeed": controls.AfSpeedEnum.Fast})
os.system("v4l2-ctl --set-ctrl wide_dynamic_range=0 -d /dev/v4l-subdev0")

s = BluetoothServer(None)

try:
    while True:
        if GPIO.input(ButtonPin) == 0:
            print("Press Button")
            picam2.start_and_capture_files("hdr2.jpg", num_files=1, delay=1)
            GPIO.output(BuzzerPin,1)
            sleep(0.2)
            GPIO.output(BuzzerPin,0)
            # uncomment this prt of code to sent image data
            '''
            with open("hdr2.jpg", "rb") as file:
                data = file.read()
            encoded_data = base64.b64encode(data).decode('utf-8')
            s.send(encoded_data)
            '''
            data = "Hi! this is test of sending data" # comment this line if you want to switch to sent data
            s.send(data)
            sleep(0.01)
            picam2.start(show_preview=True)
finally:
    picam2.stops_preview()
    picam2.stop()
    pause()
    GPIO.cleanup()
    os.system("v4l2-ctl --set-ctrl wide_dynamic_range=0 -d /dev/v4l-subdev0")