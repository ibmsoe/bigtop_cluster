#!/bin/bash

for governor in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo performance | sudo tee $governor
done

sudo cpufreq-info
sudo cpufreq-set --governor performance
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
sudo ppc64_cpu --smt=8
