---
layout: default
---

# STM32-based Virtual Frequency Counter

<style>
a.button, a.button:visited {
    display: inline-block;
    padding: 0.5em 1.2em;
    text-align: left;
    border-radius: 0.5em;

    background: #1756a9;
    color: #fff;
}

a.button:hover, a.button:active {
    background: #3776c9;
    color: #fff;

    text-decoration: none;
}

hr {
    border: none;
    border-top: 1px solid #ddd;
    margin: 2em 0em 2em 0em;
}

.button hr {
    margin: 0.3em 0em 0.3em 0em;
}
</style>

<div style="text-align: center">
<a href="https://github.com/mcejp/virtual-counter/releases/download/v21.02/virtual-counter-21.02.zip" class="button">
<div style="display: flex; flex-direction: row; align-items: center">
    <div style="margin-right: 1.5em">
        <svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" height="3.5em" viewBox="0 0 438.533 438.533" style="display: block; fill: #fff" xml:space="preserve"><g><path d="M409.133,109.203c-19.608-33.592-46.205-60.189-79.798-79.796C295.736,9.801,259.058,0,219.273,0 c-39.781,0-76.47,9.801-110.063,29.407c-33.595,19.604-60.192,46.201-79.8,79.796C9.801,142.8,0,179.489,0,219.267 c0,39.78,9.804,76.463,29.407,110.062c19.607,33.592,46.204,60.189,79.799,79.798c33.597,19.605,70.283,29.407,110.063,29.407 s76.47-9.802,110.065-29.407c33.593-19.602,60.189-46.206,79.795-79.798c19.603-33.596,29.403-70.284,29.403-110.062 C438.533,179.485,428.732,142.795,409.133,109.203z M353.742,297.208c-13.894,23.791-32.736,42.633-56.527,56.534 c-23.791,13.894-49.771,20.834-77.945,20.834c-28.167,0-54.149-6.94-77.943-20.834c-23.791-13.901-42.633-32.743-56.527-56.534 c-13.897-23.791-20.843-49.772-20.843-77.941c0-28.171,6.949-54.152,20.843-77.943c13.891-23.791,32.738-42.637,56.527-56.53 c23.791-13.895,49.772-20.84,77.943-20.84c28.173,0,54.154,6.945,77.945,20.84c23.791,13.894,42.634,32.739,56.527,56.53 c13.895,23.791,20.838,49.772,20.838,77.943C374.58,247.436,367.637,273.417,353.742,297.208z"/><path d="M310.633,219.267H255.82V118.763c0-2.666-0.862-4.853-2.573-6.567c-1.704-1.709-3.895-2.568-6.557-2.568h-54.823 c-2.664,0-4.854,0.859-6.567,2.568c-1.714,1.715-2.57,3.901-2.57,6.567v100.5h-54.819c-4.186,0-7.042,1.905-8.566,5.709 c-1.524,3.621-0.854,6.947,1.999,9.996l91.363,91.361c2.096,1.711,4.283,2.567,6.567,2.567c2.281,0,4.471-0.856,6.569-2.567 l91.077-91.073c1.902-2.283,2.851-4.576,2.851-6.852c0-2.662-0.855-4.853-2.573-6.57 C315.489,220.122,313.299,219.267,310.633,219.267z"/></g></svg>
    </div>
    <div>
        <strong style="font-size: 130%">Download v21.02</strong>
        <div>&ndash; Measurement Tool for Windows</div>
        <div>&ndash; Firmware for supported platforms</div>
    </div>
</div>
</a>
</div>

&nbsp;

![screenshot](images/virtual-counter/screenshot.png)

---

## Supported hardware platforms

Microcontroller/kit|Firmware filename|Time base source|Wiring
-|-|-|-
STM32F042F6 (stand-alone)|<code><nobr>fw-STM32F042F6-USB_CDC</nobr></code>|internal HSI oscillator, continuously tuned from USB timing, or 8MHz crystal between pins 2, 3 (detected at start-up)|[here](virtual-counter-pinouts.html#stm32f042f6-stand-alone)
[NUCLEO-F042K6](https://www.st.com/en/evaluation-tools/nucleo-f042k6.html)|<code><nobr>fw-STM32F042K6-VCP</nobr></code>|internal HSI oscillator or 8MHz crystal between pins D7, D8 (detected at start-up)|[here](virtual-counter-pinouts.html#nucleo-f042k6)
[NUCLEO-F303RE](https://www.st.com/en/evaluation-tools/nucleo-f303re.html)|<code><nobr>fw-STM32F303RE</nobr></code>|on-board crystal|[here](virtual-counter-pinouts.html#nucleo-f303re)

The firmware is supplied in BIN, HEX and ELF formats.

## Supported operating systems

OS|Binary build provided|Driver installation necessary?
-|-|-
Windows 10|yes|none
Windows Vista/7/8/8.1|yes|maybe (see below)
Windows XP|yes|yes (see below)
macOS 10.12 or later|no|none
Linux 3.0 or later|no|none

### Installation on Windows Vista/7/8/8.1

Windows Vista should automatically install the required driver provided by STMicroelectronics through Windows Update.

### Installation on Windows XP

Windows XP doesn't ship with a USB CDC driver. It is recommended to use the [STM32 Virtual COM Port Driver](http://www.st.com/en/development-tools/stsw-stm32102.html). After installing this package, the device should be recognized automatically.

### Installation on Linux

No driver is required on Linux-based systems, however it may be necessary to add a _udev_ rule to make the device accessible to non-root users.

The location of _udev_ configuration varies with distribution. For example, on Fedora 32 a file can be created at `/etc/udev/rules.d/99-virtualcounter.rules` with the following contents:

```
SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="5740", \
    ENV{ID_MM_DEVICE_IGNORE}="1", \
    MODE:="0666"
```

This ensures that the operating system will not attempt to use the device as a data modem and that the device will be available to all users.

## More documentation

- <a href="https://dspace.cvut.cz/handle/10467/68574">Bachelor thesis&ensp;<svg version="1.0" xmlns="http://www.w3.org/2000/svg" height="1em" viewBox="0 0 900 600"><rect width="900" height="600" fill="#d7141a"/><rect width="900" height="300" fill="#fff"/><path d="M 450,300 0,0 V 600 z" fill="#11457e"/></svg>
- [Source code](https://github.com/mcejp/virtual-counter)
- TODO

## Credits

[1](https://freeicons.io/user-interface-icons-4/download-symbol-icon-36648)
