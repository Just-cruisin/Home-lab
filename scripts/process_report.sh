#!/bin/bash
echo "Process report - $(hostname)"
echo "---------------------"
echo "Generated $(date)"
echo "Top 5 by CPU"
ps -eo pid,pcpu,pmem,comm --sort=-pcpu | head -6
echo ""
echo "Top 5 by memory"
ps -eo pid,pcpu,pmem,comm --sort=-pmem | head -6
