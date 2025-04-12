// Vector Multiplier Testbench
// This testbench verifies the functionality of the vector_multiplier module

`timescale 1ns/1ps

module vector_multiplier_tb;
    // Parameters (can be overridden from command line during compilation)
    parameter VECTOR_SIZE = 8;
    parameter DATA_WIDTH = 16;
    
    // Testbench signals
    reg clk;
    reg rst_n;
    reg start;
    reg [DATA_WIDTH*VECTOR_SIZE-1:0] vector_a;
    reg [DATA_WIDTH*VECTOR_SIZE-1:0] vector_b;
    wire [DATA_WIDTH*VECTOR_SIZE-1:0] result;
    wire done;
    
    // Local variables for test verification
    reg [DATA_WIDTH-1:0] expected_results [0:VECTOR_SIZE-1];
    reg [DATA_WIDTH-1:0] a_elements [0:VECTOR_SIZE-1];
    reg [DATA_WIDTH-1:0] b_elements [0:VECTOR_SIZE-1];
    integer i, errors;
    
    // Instantiate the vector multiplier
    vector_multiplier #(
        .VECTOR_SIZE(VECTOR_SIZE),
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .vector_a(vector_a),
        .vector_b(vector_b),
        .result(result),
        .done(done)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock (10ns period)
    end
    
    // Helper function to extract element from result vector
    function [DATA_WIDTH-1:0] get_result_element;
        input integer index;
        begin
            get_result_element = result[DATA_WIDTH*(index+1)-1 -: DATA_WIDTH];
        end
    endfunction
    
    // Test sequence
    initial begin
        // Initialize
        rst_n = 0;
        start = 0;
        vector_a = 0;
        vector_b = 0;
        errors = 0;
        
        // Initialize test data arrays
        for (i = 0; i < VECTOR_SIZE; i = i + 1) begin
            a_elements[i] = 0;
            b_elements[i] = 0;
            expected_results[i] = 0;
        end
        
        // Reset release
        #20 rst_n = 1;
        #10;
        
        // Test case 1: Sequential values
        $display("\nTest Case 1: Sequential Values");
        for (i = 0; i < VECTOR_SIZE; i = i + 1) begin
            a_elements[i] = i + 1;
            b_elements[i] = VECTOR_SIZE - i;
            expected_results[i] = a_elements[i] * b_elements[i];
            
            // Pack elements into vectors
            vector_a[DATA_WIDTH*(i+1)-1 -: DATA_WIDTH] = a_elements[i];
            vector_b[DATA_WIDTH*(i+1)-1 -: DATA_WIDTH] = b_elements[i];
        end
        
        // Start multiplication
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion
        wait(done);
        @(posedge clk);
        
        // Verify results
        $display("Vector A: ");
        for (i = 0; i < VECTOR_SIZE; i = i + 1) begin
            $write("%d ", a_elements[i]);
        end
        $display("\nVector B: ");
        for (i = 0; i < VECTOR_SIZE; i = i + 1) begin
            $write("%d ", b_elements[i]);
        end
        $display("\nExpected Result: ");
        for (i = 0; i < VECTOR_SIZE; i = i + 1) begin
            $write("%d ", expected_results[i]);
        end
        $display("\nActual Result: ");
        for (i = 0; i < VECTOR_SIZE; i = i + 1) begin
            $write("%d ", get_result_element(i));
        end
        $display("");
        
        // Check for errors
        for (i = 0; i < VECTOR_SIZE; i = i + 1) begin
            if (get_result_element(i) !== expected_results[i]) begin
                $display("ERROR at index %0d: Expected %0d, Got %0d", 
                          i, expected_results[i], get_result_element(i));
                errors = errors + 1;
            end
        end
        
        // Test case 2: All ones
        $display("\nTest Case 2: All Ones");
        for (i = 0; i < VECTOR_SIZE; i = i + 1) begin
            a_elements[i] = 1;
            b_elements[i] = 1;
            expected_results[i] = 1;
            
            // Pack elements into vectors
            vector_a[DATA_WIDTH*(i+1)-1 -: DATA_WIDTH] = a_elements[i];
            vector_b[DATA_WIDTH*(i+1)-1 -: DATA_WIDTH] = b_elements[i];
        end
        
        // Start multiplication
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion
        wait(done);
        @(posedge clk);
        
        // Verify results
        $display("Vector A: All 1's");
        $display("Vector B: All 1's");
        $display("Expected Result: All 1's");
        $display("Actual Result: ");
        for (i = 0; i < VECTOR_SIZE; i = i + 1) begin
            $write("%d ", get_result_element(i));
        end
        $display("");
        
        // Check for errors
        for (i = 0; i < VECTOR_SIZE; i = i + 1) begin
            if (get_result_element(i) !== expected_results[i]) begin
                $display("ERROR at index %0d: Expected %0d, Got %0d", 
                          i, expected_results[i], get_result_element(i));
                errors = errors + 1;
            end
        end
        
        // Test case 3: Maximum values
        $display("\nTest Case 3: Maximum Values (within DATA_WIDTH)");
        for (i = 0; i < VECTOR_SIZE; i = i + 1) begin
            a_elements[i] = (1 << (DATA_WIDTH/2)) - 1; // Half the max value
            b_elements[i] = (1 << (DATA_WIDTH/2)) - 1; // to avoid overflow
            expected_results[i] = a_elements[i] * b_elements[i];
            
            // Pack elements into vectors
            vector_a[DATA_WIDTH*(i+1)-1 -: DATA_WIDTH] = a_elements[i];
            vector_b[DATA_WIDTH*(i+1)-1 -: DATA_WIDTH] = b_elements[i];
        end
        
        // Start multiplication
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for completion
        wait(done);
        @(posedge clk);
        
        // Verify results
        $display("Vector A: All %0d", a_elements[0]);
        $display("Vector B: All %0d", b_elements[0]);
        $display("Expected Result: All %0d", expected_results[0]);
        $display("Actual Result: ");
        for (i = 0; i < VECTOR_SIZE; i = i + 1) begin
            $write("%d ", get_result_element(i));
        end
        $display("");
        
        // Check for errors
        for (i = 0; i < VECTOR_SIZE; i = i + 1) begin
            if (get_result_element(i) !== expected_results[i]) begin
                $display("ERROR at index %0d: Expected %0d, Got %0d", 
                          i, expected_results[i], get_result_element(i));
                errors = errors + 1;
            end
        end
        
        // Report test results
        if (errors == 0) begin
            $display("\nTEST PASSED: All vector multiplications completed successfully!");
        end else begin
            $display("\nTEST FAILED: %0d errors detected.", errors);
        end
        
        // End simulation
        #20 $finish;
    end
    
    // Monitor important signals
    initial begin
        $monitor("Time=%0t: start=%b, done=%b", $time, start, done);
    end
    
endmodule