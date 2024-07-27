# Spartan-6 DSP48A1 Design and Testbench
This repository contains the design and testbench for the DSP48A1 slice of the Spartan-6 FPGA family. The Spartan-6 family is known for its high ratio of DSP48A1 slices to logic, making it ideal for math-intensive applications.

## Project Overview
This project involves designing the DSP48A1 slice, creating a testbench for verification, and running the design flow using Vivado and QuestaSim. The design includes various pipeline registers and control inputs to handle complex arithmetic operations efficiently.

## Key Features
DSP48A1 Slice Design: Implementation of the DSP48A1 slice with pipeline registers and configurable attributes.
Testbench: Comprehensive testbench using directed test patterns to verify the design.
Vivado Design Flow: Detailed steps for running elaboration, synthesis, and implementation in Vivado, ensuring no design check errors.
QuestaSim Integration: Usage of do files to run the QuestaSim flow and capture waveforms for analysis.

## Directory Structure
Top Module (DSP48A1): Contains the RTL code for the DSP48A1 slice.
Block Module (BLOCK): The building block used in this design.
Testbench: Includes the testbench code and do file for simulation.
Constraints File: Timing constraints file for the design.
Vivado/: Project files for elaboration, synthesis, and implementation in Vivado.
results/: Output snippets from QuestaSim and Vivado, including waveforms, schematics, utilization, and timing reports.

## Some Snippets :
### Elaborated Design Schematic : 
![image](https://github.com/user-attachments/assets/2902c4dd-784e-4f8a-a4f3-c5fd34f73f24)
### Device After Implementation on FPGA Artex7 - Basys 3
![image](https://github.com/user-attachments/assets/95f586f6-65b4-4049-b658-0dbcec4763fd)

## For The Whole Documentation : 
https://drive.google.com/file/d/1DfGBsYvFTYrQpeRnB68V5Xww_MKK0nG5/view?usp=drive_link

## References :
Xilinx User Guide: https://docs.amd.com/v/u/en-US/ug389
