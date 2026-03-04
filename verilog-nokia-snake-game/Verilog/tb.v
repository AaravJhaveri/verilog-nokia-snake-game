`timescale 1ns / 1ns
`include "ds.v"

module testbench;
    integer file;
    integer char;
    reg [0:3] board [19:0][19:0];
    integer piece;
    reg [4:0] head_coords [0:1];
    reg [4:0] tail_coords [0:1];
    reg [4:0] apple_coords [0:1];
    integer snake_body;
    reg [(5 * 2 * 21) - 1:0] snake_body_coords;
    integer cnt;
    wire [4:0] apple_x;
    wire [4:0] apple_y;
    reg flag;

    RandomAppleGenerator #(
        .EXCLUDED_SIZE(21)
    ) inst1 (
        .apple_x(apple_x),
        .apple_y(apple_y),
        .excluded(snake_body_coords),
        .flag(flag)
    );

    initial begin

        // deep's code starts...

        file = $fopen("input.txt", "r");

        if (file == 0) begin
            $display("Error opening the File!!");
            $finish;
        end

        char = $fgetc(file);
        if (char != -1) begin
            if (char == "f" || char == "\n" || char == " ") begin
                $finish;
            end
            $display("Character read from file: |%c|", char);
        end
        else begin
            $finish;
        end
        
        $fclose(file);

        file = $fopen("output.txt", "r");

        if (file == 0) begin
            $display("Error opening the file!!");
            $finish;
        end

        for (integer i = 0; i < 24; i++) begin
            piece = $fgetc(file);
        end

        snake_body = 0;

        for (integer i = 0; i < 20; i++) begin
            for (integer j = 0; j < 20; j++) begin
                piece = $fgetc(file);
                if (piece != -1) begin
                    if (piece == ".") begin
                        board[i][j] = 0;
                    end else if (piece == "A") begin
                        board[i][j] = 1;
                    end else if (piece == "S") begin
                        board[i][j] = 2;
                        snake_body = snake_body + 1;
                    end else if (piece == "H") begin
                        board[i][j] = 3;
                        snake_body = snake_body + 1;
                    end
                end
            end
            piece = $fgetc(file);
            piece = $fgetc(file);
            piece = $fgetc(file);
        end

        cnt = 0;
        // aarav's code starts...

        for (integer i = 0; i < 20; i++) begin
            for (integer j = 0; j < 20; j++) begin
                if (board[i][j] == 3) begin
                    head_coords[0] = i;
                    head_coords[1] = j;
                end else if (board[i][j] == 2 && ((((i < 19 ? board[i+1][j] : 1) == 2) + ((i > 0 ? board[i-1][j] : 1) == 2) + ((j < 19 ? board[i][j+1] : 1) == 2) + ((j > 0 ? board[i][j-1] : 1) == 2)) <= 1) && ((((i < 19 ? board[i+1][j] : 0) == 3) + ((i > 0 ? board[i-1][j] : 0) == 3) + ((j < 19 ? board[i][j+1] : 0) == 3) + ((j > 0 ? board[i][j-1] : 0) == 3)) == 0))
                begin
                    tail_coords[0] = i;
                    tail_coords[1] = j;
                end else if (board[i][j] == 2) begin
                    snake_body_coords[(cnt * 10) +: 5] = i;
                    snake_body_coords[(cnt * 10) + 5 +: 5] = j;
                    cnt = cnt + 1;
                end else if (board[i][j] == 1) begin
                    apple_coords[0] = i;
                    apple_coords[1] = j;
                end
            end
        end

        snake_body_coords[(cnt * 10) +: 5] = tail_coords[0];
        snake_body_coords[(cnt * 10) + 5 +: 5] = tail_coords[1];
        cnt = cnt + 1;

        if (char == "l") begin
            if (head_coords[1] > 0 && board[head_coords[0]][head_coords[1] - 1] != 2) begin
                snake_body_coords[(cnt * 10) +: 5] = head_coords[0];
                snake_body_coords[(cnt * 10) + 5 +: 5] = head_coords[1] - 1;
                if (head_coords[0] == apple_coords[0] && head_coords[1] - 1 == apple_coords[1]) begin
                    flag = 1;
                    #5;
                    board[apple_x][apple_y] = 1;
                end else begin
                    board[tail_coords[0]][tail_coords[1]] = 0;
                end
                board[head_coords[0]][head_coords[1]] = 2;
                board[head_coords[0]][head_coords[1] - 1] = 3;
            end
        end
        else if (char == "r") begin
            if (head_coords[1] < 19 && board[head_coords[0]][head_coords[1] + 1] != 2) begin
                snake_body_coords[(cnt * 10) +: 5] = head_coords[0];
                snake_body_coords[(cnt * 10) + 5 +: 5] = head_coords[1] + 1;
                if (head_coords[0] == apple_coords[0] && head_coords[1] + 1 == apple_coords[1]) begin
                    flag = 1;
                    #5;
                    board[apple_x][apple_y] = 1;
                end else begin
                    board[tail_coords[0]][tail_coords[1]] = 0;
                end
                board[head_coords[0]][head_coords[1]] = 2;
                board[head_coords[0]][head_coords[1] + 1] = 3;
            end
        end
        else if (char == "u") begin
            if (head_coords[0] > 0 && board[head_coords[0] - 1][head_coords[1]] != 2) begin
                snake_body_coords[(cnt * 10) +: 5] = head_coords[0] - 1;
                snake_body_coords[(cnt * 10) + 5 +: 5] = head_coords[1];
                if (head_coords[0] - 1 == apple_coords[0] && head_coords[1] == apple_coords[1]) begin
                    flag = 1;
                    #5;
                    board[apple_x][apple_y] = 1;
                end else begin
                    board[tail_coords[0]][tail_coords[1]] = 0;
                end
                board[head_coords[0]][head_coords[1]] = 2;
                board[head_coords[0] - 1][head_coords[1]] = 3;
            end
        end
        else if (char == "d") begin
            if (head_coords[0] < 19 && board[head_coords[0] + 1][head_coords[1]] != 2) begin
                snake_body_coords[(cnt * 10) +: 5] = head_coords[0] + 1;
                snake_body_coords[(cnt * 10) + 5 +: 5] = head_coords[1];
                if (head_coords[0] + 1 == apple_coords[0] && head_coords[1] == apple_coords[1]) begin
                    flag = 1;
                    #5;
                    $display("apple coords: %d %d", apple_x, apple_y);
                    board[apple_x][apple_y] = 1;
                end else begin
                    board[tail_coords[0]][tail_coords[1]] = 0;
                end
                board[head_coords[0]][head_coords[1]] = 2;
                board[head_coords[0] + 1][head_coords[1]] = 3;
            end
        end
        else if (char == "a") begin
            for (integer i = 0; i < 20; i++) begin
                for (integer j = 0; j < 20; j++) begin
                    if (i == 2 && j == 2) begin
                        board[i][j] = 2;
                    end else if (i == 2 && j == 3) begin
                        board[i][j] = 3;
                    end else if (i == 10 && j == 10) begin
                        board[i][j] = 1;
                    end else begin
                        board[i][j] = 0;
                    end
                end
            end
        end

        // deep's part continued...

        $fclose(file);

        file = $fopen("output.txt", "w");

        if (file == 0) begin
            $display("Error opening the file!!");
            $finish;
        end

        $fclose(file);

        file = $fopen("output.txt", "a");

        if (file == 0) begin
            $display("Error opening the file!!");
            $finish;
        end

        $fwrite(file, "______________________\n");
        for (integer i = 0; i < 20; i++) begin
            $fwrite(file, "|");
            for (integer j = 0; j < 20; j++) begin
                if (board[i][j] == 0) begin
                    $fwrite(file, ".");
                end else if (board[i][j] == 1) begin
                    $fwrite(file, "A");
                end else if (board[i][j] == 2) begin
                    $fwrite(file, "S");
                end else if (board[i][j] == 3) begin
                    $fwrite(file, "H");
                end
            end
            $fwrite(file, "|\n");
        end
        $fwrite(file, "______________________");

        $fclose(file);

        $finish;
    end
endmodule