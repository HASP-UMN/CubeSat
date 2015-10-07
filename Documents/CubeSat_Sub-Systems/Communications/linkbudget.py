#!/usr/bin/python3.4

#   Link budget calculation for Senior Design Cube Sat
#   Author: Benjamin Setterholm
#   
#   Goal: Determine roughly the amount of time necessary to transmit 1 MiB of
#         data
#   
#   General form for link budget equation:
#   EIRP = P_T - L_T + G_T
#       EIRP - Equivalent Isotropic Radiated Power - (dBm)
#       P_T  - Transmission Power                  - (dBm)
#       L_T  - Transmission Loss                   - (dB)
#       G_T  - Transmission Antenna Gain           - (dB)
#   
#   If you wish to run/modify this file, you must have Python 3 installed along
#   with modules listed in the 'Module Import' cell below.  The easiest way to
#   obtain all required components is to install the Pyzo computing enviromnment
#   which can be obtained at www.pyzo.org/downloads.html
#   
#   References:
#     > http://paginas.fe.up.pt/~ee97054/Link%20Budget.pdf


##  Module Import

import numpy as np


##  Calculation parameters.
#   All parameters MUST be expressed in MKS units.

#   Relevant fundamental constants.  DO NOT MODIFY!
c = 299792458       # m/s - speed of light

#   Orbital parameters
altitude = 4.1e5    # m     # GUESS! - Based on ISS altitude
r = altitude        # distance to reciever. CHANGE TO FUNCTION WITH MORE INFO

#   Communication System parameters
gain = 1            # Placeholder value
frequency = 915e6   # Hz - From MM2_TTL Radio Data Sheet


## Free Space Loss

FSL = 10*np.log10((4*np.pi*r*frequency/c)**2)

## Atmospheric Losses


## Pointing Losses


## Ground Station Losses
#   Look up recieving station particulars


## EIRP Calculation


## Data Transfer Rate
#   How does link budget translate to data transfer rate?