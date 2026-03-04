module RandomAppleGenerator #(
    parameter EXCLUDED_SIZE = 2
)(
    output reg [4:0] apple_x,
    output reg [4:0] apple_y,
    input [(5 * 2 * EXCLUDED_SIZE) - 1:0] excluded,  // Flattened exclusion array
    input flag
);
    reg [4:0] x, y;
    reg done;
    integer i;
    reg [4:0] excluded_x, excluded_y;
    always @(*) begin
        if (flag) begin
            done = 0;
            while (!done) begin
                x = $urandom % 20;
                y = $urandom % 20;
                done = 1;
                for (i = 0; i < EXCLUDED_SIZE; i++) begin
                    excluded_x = excluded[(i * 10) +: 5];
                    excluded_y = excluded[(i * 10) + 5 +: 5];
                    if (x == excluded_x && y == excluded_y) begin
                        done = 0;
                        i = EXCLUDED_SIZE;
                    end
                end
            end

            apple_x = x;
            apple_y = y;
        end
    end
endmodule