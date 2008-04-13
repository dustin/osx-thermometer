# Using Thermometer

For the most part, this app can be used without modification. However, if you
would like it to display your own thermometers, you can do this by providing a
URL that provides temperatures.

## HTTP

By default, the app displays temperatures at my house via the following URL:

    http://bleu.west.spy.net/therm/Temperature

This URL is expected to provide a textual list of results where each line is
the name of a thermometer. For example, consider the following output from
mine:

    bedroom
    garage
    livingroom
    guestroom
    newmachineroom
    backyard
			
That creates six individual cells for the display. Each cell is queried via the following URL:

    http://bleu.west.spy.net/therm/Temperature?temp=name

Where name is replaced with the name of the thermometer. This URL is expected
to return the current reading of the given thermometer in celsius. For example:
16.86

## LEMP

Thermometer also supports LEMP, which is (Live|Lightweight|Lame) Environment
Monitoring Protocol. To use LEMP, you may enter a URL in the following format:

    lemp://host[:port]/

8181 is the default port number. To see what LEMP looks like (sorry, no formal
documentation), you can use telnet or netcat or something to connect to port
8181 of lemp.west.spy.net which is providing a live feed of temperature data
from my house.

# The Display

Each thermometer contains two basic data elements:

* The current reading (below the center)
* The trend (above the center)
* The current reading is the reading as of the last update (seen at the bottom of the window). The trend is the difference between the current reading and the oldest reading you have up to ten samples ago.
* For example, if your sample rate is 300 (once every five minutes), and your current reading is 35.81, and the trend is -0.21, then the temperature has fallen .21 degrees in the last 50 minutes as long as you've had the application running at least that long.

# Screenshots

## Main Window

![main window](http://public.west.spy.net/therm/main.png)

## Log Window

![log window](http://public.west.spy.net/therm/log.png)

## App Menu

![app menu](http://public.west.spy.net/therm/menu.png)
