`timescale 1ns/1ps

module Testbench;

    // Clock and reset signals
    logic clk;
    logic rst_n;
    
    // APB interface
    logic        PSEL;
    logic        PENABLE;
    logic        PWRITE;
    logic [31:0] PADDR;
    logic [31:0] PWDATA;
    logic [31:0] PRDATA;
    logic        PREADY;
    logic        PSLVERR;
    
    // Sync generator output
    logic SYNC_OUT;
    
    // Clock generation
    initial begin
        clk = 0;
        $display("Starting clock generation...");
        forever #5 clk = ~clk;
    end
    
    // Reset generation
    initial begin
        rst_n = 0;
        $display("Reset asserted");
        #20 rst_n = 1;
        $display("Reset deasserted at time %0t", $time);
    end
    
    // Master instantiation
    apb_master master_inst (
        .PCLK(clk),
        .PRESETn(rst_n),
        .PSEL(PSEL),
        .PENABLE(PENABLE),
        .PWRITE(PWRITE),
        .PADDR(PADDR),
        .PWDATA(PWDATA),
        .PRDATA(PRDATA),
        .PREADY(PREADY),
        .PSLVERR(PSLVERR)
    );
    
    // Slave instantiation (with SYNC_OUT)
    apb_slave slave_inst (
        .PCLK(clk),
        .PRESETn(rst_n),
        .PSEL(PSEL),
        .PENABLE(PENABLE),
        .PWRITE(PWRITE),
        .PADDR(PADDR),
        .PWDATA(PWDATA),
        .PRDATA(PRDATA),
        .PREADY(PREADY),
        .PSLVERR(PSLVERR),
        .SYNC_OUT(SYNC_OUT)
    );
    
    // Test sequence
    initial begin
        logic [31:0] read_data;
        logic [15:0] counter_before;
        logic [15:0] counter_after;
        
        // Wait for reset completion
        #30;
        $display("");
        $display("************************************************");
        $display("APB SYNC GENERATOR TEST STARTED - VARIANT 5");
        $display("************************************************");
        $display("");
        
        // Test 1: Reset and default values
        $display("=== TEST 1: RESET AND DEFAULT VALUES ===");
        
        // Read all registers after reset
        master_inst.apb_read(32'h00000000, read_data); // Control
        $display("Control after reset: 0x%08h (expected: 0x00000000)", read_data);
        
        master_inst.apb_read(32'h00000004, read_data); // Period  
        $display("Period after reset: 0x%08h (expected: 0x00000005)", read_data);
        
        master_inst.apb_read(32'h00000008, read_data); // Status
        $display("Status after reset: 0x%08h", read_data);
        $display("SYNC_OUT after reset: %b (expected: 0)", SYNC_OUT);
        
        #50;
        
        // Test 2: Configure period and start generator
        $display("");
        $display("=== TEST 2: CONFIGURE PERIOD AND START ===");
        
        // Set period = 5 ticks
        master_inst.apb_write(32'h00000004, 32'h00000005);
        $display("Period set to 5 ticks");
        
        // Start generator (bit 0 = 1)
        master_inst.apb_write(32'h00000000, 32'h00000001);
        $display("Generator started (control = 0x00000001)");
        
        // Wait for several periods to observe behavior
        $display("Observing generator for 40 clock cycles...");
        repeat(40) @(posedge clk);
        
        // Read status
        master_inst.apb_read(32'h00000008, read_data);
        $display("Status after running: 0x%08h", read_data);
        $display("SYNC_OUT: %b", SYNC_OUT);
        
        #20;
        
        // Test 3: Stop generator
        $display("");
        $display("=== TEST 3: STOP GENERATOR ===");
        
        // Stop (bit 0 = 0)
        master_inst.apb_write(32'h00000000, 32'h00000000);
        $display("Generator stopped (control = 0x00000000)");
        
        // Verify counter is frozen
        master_inst.apb_read(32'h00000008, read_data);
        $display("Status before waiting: 0x%08h", read_data);
        counter_before = read_data[31:16];
        
        // Wait several cycles - counter should not change
        repeat(10) @(posedge clk);
        
        master_inst.apb_read(32'h00000008, read_data);
        counter_after = read_data[31:16];
        $display("Counter before: 0x%04h, after: 0x%04h", counter_before, counter_after);
        
        if (counter_before == counter_after)
            $display("PASS: Counter frozen when generator stopped");
        else
            $display("FAIL: Counter changed when generator stopped");
            
        #20;
        
        // Test 4: Counter reset
        $display("");
        $display("=== TEST 4: COUNTER RESET ===");
        
        // Restart generator
        master_inst.apb_write(32'h00000000, 32'h00000001);
        $display("Generator restarted");
        
        // Wait a few cycles to get some counter value
        repeat(8) @(posedge clk);
        
        // Activate reset (bit 1 = 1)
        master_inst.apb_write(32'h00000000, 32'h00000003);
        $display("Reset activated (control = 0x00000003)");
        @(posedge clk);
        
        // Deactivate reset, keep running
        master_inst.apb_write(32'h00000000, 32'h00000001);
        $display("Reset deactivated, generator running (control = 0x00000001)");
        
        // Verify counter was reset
        master_inst.apb_read(32'h00000008, read_data);
        $display("Status after reset: 0x%08h", read_data);
        
        if (read_data[31:16] == 16'h0000)
            $display("PASS: Counter reset successfully");
        else
            $display("FAIL: Counter not reset, value = 0x%04h", read_data[31:16]);
            
        #50;
        
        // Test completion
        $display("");
        $display("************************************************");
        $display("APB SYNC GENERATOR TEST COMPLETED");
        $display("************************************************");
        $display("All tests finished successfully!");
        $display("Simulation time: %0t ns", $time);
        $display("Final SYNC_OUT: %b", SYNC_OUT);
        $display("************************************************");
        $display("");
        
        #50;
        //$finish;
    end
    
    // Monitor APB transactions and sync output
    initial begin
        $monitor("Time: %0t | SYNC_OUT=%b | APB: PSEL=%b PENABLE=%b PWRITE=%b PADDR=0x%02h", 
                 $time, SYNC_OUT, PSEL, PENABLE, PWRITE, PADDR[7:0]);
 
   
    end

endmodule