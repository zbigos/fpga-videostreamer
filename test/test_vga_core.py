import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles
import random

async def reset(dut):
    dut.reset <= 1
    await ClockCycles(dut.clk, 5)
    dut.reset <= 0

# irl this would run at 25nS period. But cocotb 
# cries due to precision errors, so we run the sim
# 8x times slower.
# a single VGA frame takes 663168 cycles, so we will
# simulate 5 of them to be on the safe side
@cocotb.test()
async def test_vga_core(dut):
    clock = Clock(dut.clk, 250, units="ns")
    cocotb.fork(clock.start())
    await reset(dut)

    await ClockCycles(dut.clk, 400000)