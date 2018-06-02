import signal
import sys

from pymata_aio.pymata3 import PyMata3
from pymata_aio.constants import Constants

from lib.mqtt import MQTTClient
from lib.datalogger import DataLogger

## ---------------------------------------------------------------------
## --
## --                  Global Variables
## --
## ---------------------------------------------------------------------

VERBOSE = 1
datalogger = None

LED_PIN = 13
BUT_PIN = 12
SPK_PIN = 10

SND_PIN = 0    # A0
POT_PIN = 2    # A2


## ---------------------------------------------------------------------
## --
## --                  Signal Handlers
## --
## ---------------------------------------------------------------------
def _signal_handler(sig, frame):
    """
    Handle a terminate signal, either through the keyboard (^C - SIGINT)
    or a software signal (SIGTERM)

    :param sig: signal SIGINT, SIGTERM
    :param frame: context
    :return:
    """
    global datalogger

    # Just striaght out print, since we recieve ^C (must be a human?)
    print("You have pressed ^C, see ya later!")
    if datalogger.board is not None:
        board.shutdown()
    if datalogger.mqtt is not None:
        mqtt.disconnect()
    sys.exit(0)

## ---------------------------------------------------------------------
## --
## --                  Define Callbacks
## --
## ---------------------------------------------------------------------
def _cb_analog_map(amap):
    """Print out a map of the PINs for debug info"""
    print(amap)

## ---------------------------------------------------------------------
## --
## --                  Setup()
## --
## -- 1. Set signal handlers for ^C and the SIGTERM signal
## -- 1.
## ---------------------------------------------------------------------
def setup():
    ### Set signal handlers
    signal.signal(signal.SIGINT, _signal_handler)
    signal.signal(signal.SIGTERM, _signal_handler)

    # Add sig alarm unless we are windows
    if not sys.platform.startswith('win32'):
        signal.signal(signal.SIGALRM, _signal_handler)

def loop(datalogger):
    # MQTT mesassage are processed in the background on another thread
    # This thread will be responsible to sending pusblished messages

    # Play some tones and blink some lights just for fun
    # let us know something is .
    # board.play_tone(SPK_PIN, Constants.TONE_TONE, 1000, 500)


    # board.sleep(3)
    # board.play_tone(SPK_PIN, Constants.TONE_TONE, 1000, 500)

    # board.sleep(2)
    # board.play_tone(SPK_PIN, Constants.TONE_NO_TONE, 1000, 0)
    board = datalogger.board
    board.digital_write(LED_PIN, 0)
    board.sleep(2)
    board.digital_write(LED_PIN, 1)
    board.sleep(2)

    datalogger.publish_data()
    board.sleep(2)

if __name__ == "__main__":

    # The board and mqtt variables will be set in setup()
    board = PyMata3(4)
    mqtt  = MQTTClient(broker="192.168.1.14")
    datalogger = DataLogger(board=board, mqtt=mqtt)

    # Loop endlessly until we receive a ^C or loose power
    try:
        setup()
        while True:
            loop(datalogger)

    # Capture any exceptions and try to duck out peacefully
    except RuntimeError:
        board.shutdown()
        mqtt.disconnect()
        sys.exit(0)
