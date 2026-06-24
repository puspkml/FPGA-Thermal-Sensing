# FPGA Thermal Sensing using SPI protocol

A simple Verilog-based thermal sensing simulation pipeline that reads temperature data from an image, transfers it through an SPI interface, and generates pseudo-colored RGB output.

## Overview

This project emulates the workflow of a thermal imaging sensor using a fully simulated digital pipeline.

An input image is first converted into thermal intensity values using a Python script. The generated data is stored as a `.hex` file and then consumed by the Verilog modules during simulation.

The data flow is:

```text
Image
  ↓
Python Converter
  ↓
.hex Temperature Data
  ↓
sensor.v
  ↓
spi_master.v
  ↓
lut.v
  ↓
RGB Output
```

## Modules

### sensor.v

Acts as the thermal sensor.

* Reads 16 × 16 thermal data from a `.hex` file
* Provides temperature values sequentially
* Mimics a sensor streaming thermal information

### spi_master.v

Handles SPI communication.

* Receives thermal data from the sensor
* Implements SPI transfer logic
* Synchronizes and processes incoming data

### lut.v

Pseudo-color lookup table.

* Maps raw temperature values to RGB values
* Produces thermal color gradients
* Generates visual output suitable for display

### tb_final.v

Simulation testbench.

* Connects all modules together
* Drives the complete thermal sensing pipeline
* Generates waveform outputs for verification

## Simulation Tools

* Icarus Verilog (iverilog)
* GTKWave

## Running

Compile:

```bash
iverilog -o sim sensor.v spi_master.v lut.v tb_final.v
```

Run:

```bash
vvp sim
```

Open waveform:

```bash
gtkwave thermal.vcd
```

## Motivation

Thermal cameras convert temperature information into colorized images that are easier for humans to interpret. This project recreates a simplified version of that process entirely in simulation, making it useful for learning SPI communication, image-based data processing, and hardware design workflows.

## Future Work

* Higher image resolutions
* Real-time sensor interfaces
* FPGA implementation
* HDMI/VGA display output
* Advanced thermal color maps

## Author

Puspa Kamal Rai
M.Sc. Physics
Sri Sathya Sai Institute of Higher Learning
# FPGA-Thermal-Sensing
