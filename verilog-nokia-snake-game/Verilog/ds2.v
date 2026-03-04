module snake_logic(
    input [1:0] direction,
    input grow,
    output reg [3:0] head_x, head_y,
    output reg collision,
    output reg[1:0] board[0:15][0:15]
);
    parameter MAX_LENGTH = 16;
    parameter EMPTY = 2'b00;
    parameter SNAKE = 2'b01;
    reg[3:0] snake_x[0:MAX_LENGTH-1];
    reg[3:0] snake_y[0:MAX_LENGTH-1];
    reg[3:0] length = 4;

    integer i,j; 
    initial begin
        head_x = 4'd8; // snake at centre of grid
        head_y = 4'd8;
        collision = 0; 
        for(i = 0; i < 16; i++) begin
            for(j = 0; j < 16; j++) begin
                board[i][j] = EMPTY;
            end
        end

        board[head_x][head_y] = SNAKE
    end

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            head_x <= 4'd8;
            head_y <= 4'd8;
            length <= 4;
            collision <= 0;

            for(i = 0; i < 16; i++) begin
                for(j = 0; j < 16; j++) begin
                    board[i][j] = EMPTY;
                end
            end

            board[head_x][head_y] = SNAKE
        end
        else begin
            collision = 0;

        // Direction logic
        case(direction)
            2'b00 : if(head_y > 0)  head_y <= head_y - 1; // up
            2'b01 : if(head_y < 4'd15)  head_y <= head_y + 1; // down
            2'b10 : if(head_x > 0)  head_x <= head_x - 1; // left
            2'b11 : if(head_x < 4'd15)  head_y <= head_x + 1; // right
        endcase

        // Shifting each body parts
        for(i = length - 1; i > 0; i = i - 1) begin
            snake_x[i] <= snake_x[i-1];
            snake_y[i] <= snake_y[i-1];
        end
        snake_x[0] <= head_x;
        snake_y[0] <= head_y;

        // collision with walls
        if(head_x == 4'd0 && direction == 2'b10 || // left
           head_x == 4'd15 && direction == 2'b11 || // right
           head_y == 4'd0 && direction == 2'b00 ||  // up
           head_y == 4'd15 && direction == 2'b01)  // down
        begin
            collision <= 1;
        end        

        // self-collision
        integer i;
            for(i = 0; i < length; i++) begin
                if(head_x == snake_x[i] && head_y == snake_y[i]) begin
                    collision <= 1;
                end
            end

        // Growth
            if(grow && length <= MAX_LENGTH) begin
                length <= length + 1;
            end
        end
    end
endmodule

module snake_game(
    input clk,
    input reset,
    input [1:0] direction, 
    output reg[3:0] head_x, head_y,  
    output reg[3:0] food_x, food_y,  
    output reg grow,  
    output reg[3:0] length  
);
    parameter GRID_SIZE = 16;
    parameter MAX_LENGTH = 16;
    reg[3:0] snake_body_x[0:MAX_LENGTH-1];
    reg[3:0] snake_body_y[0:MAX_LENGTH-1];
    reg[3:0] temp_x, temp_y;
    reg[3:0] food_spawn;

    always @(posedge clk) begin
        if(reset) begin
            head_x <= 4'd8;
            head_y <= 4'd8;
            food_x <= 4'd4;
            food_y <= 4'd4;
            grow <= 0;
            length <= 4;
            food_spawn <= 0;
        end
        else begin
            case(direction)
            2'b00 : if(head_y > 0)  head_y <= head_y - 1; // up
            2'b01 : if(head_y < 4'd15)  head_y <= head_y + 1; // down
            2'b10 : if(head_x > 0)  head_x <= head_x - 1; // left
            2'b11 : if(head_y < 4'd15)  head_y <= head_x + 1; // right
            endcase
        end

        if(head_x == food_x && head_y == food_y) begin
            grow <=1;
            food_spawn <= 1;
        end
        else begin
            grow <= 0
        end

        if(food_spawn) begin
            integer valid_food_position;
            valid_food_position = 0;
            while(!valid_food_position) begin
                food_x <= $random % GRID_SIZE;
                food_y <= $random % GRID_SIZE;
                valid_food_position = 1;

                integer i;
                for(i = 0; i < length; i = i + 1) begin
                    if(food_x == snake_body_x[i] && food_y == snake_body_y[i]) begin
                        food_spawn <= 0;
                    end
                end
            end
            food_spawn <= 0;
        end            
    end
endmodule
