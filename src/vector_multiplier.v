// Vector Multiplication Accelerator
// This module implements parallel vector multiplication
// to accelerate matrix operations common in AI workloads

module vector_multiplier #(
    parameter VECTOR_SIZE = 8,     // Size of vectors to multiply
    parameter DATA_WIDTH = 16      // Width of each element
) (
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire [DATA_WIDTH*VECTOR_SIZE-1:0] vector_a,
    input wire [DATA_WIDTH*VECTOR_SIZE-1:0] vector_b,
    output reg [DATA_WIDTH*VECTOR_SIZE-1:0] result,
    output reg done
);

    // Intermediate multiplication results
    reg [DATA_WIDTH-1:0] mult_results [0:VECTOR_SIZE-1];
    
    // Control logic
    reg computing;
    
    // FSM for controlling the computation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            computing <= 1'b0;
            done <= 1'b0;
        end else begin
            if (start && !computing) begin
                computing <= 1'b1;
                done <= 1'b0;
            end else if (computing) begin
                computing <= 1'b0;
                done <= 1'b1;
            end else if (done) begin
                done <= 1'b0;
            end
        end
    end
    
    // Parallel multiplication of vector elements
    genvar i;
    generate
        for (i = 0; i < VECTOR_SIZE; i = i + 1) begin : mult_elements
            // Extract elements from input vectors
            wire [DATA_WIDTH-1:0] a_element = vector_a[DATA_WIDTH*(i+1)-1:DATA_WIDTH*i];
            wire [DATA_WIDTH-1:0] b_element = vector_b[DATA_WIDTH*(i+1)-1:DATA_WIDTH*i];
            
            // Calculate multiplication results
            always @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
                    mult_results[i] <= 0;
                end else if (start) begin
                    mult_results[i] <= a_element * b_element;
                end
            end
            
            // Update result register
            always @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
                    result[DATA_WIDTH*(i+1)-1:DATA_WIDTH*i] <= 0;
                end else if (computing) begin
                    result[DATA_WIDTH*(i+1)-1:DATA_WIDTH*i] <= mult_results[i];
                end
            end
        end
    endgenerate

endmodule