module file_read;
    integer file_o;
    integer file_i;
    reg[7:0] char;
    integer char_i;
    integer i=0;
    integer j=0;
    integer ref_sbody=0;
    reg[3:0] board[0:19][0:19];
    reg[3:0] nboard[0:21][0:21];
    integer flag = 0;
    reg[10:0] sbody_cor[0:399];
    reg[10:0] shead_cor[0:1];
    reg[10:0] apple_cor[0:1];
    reg[10:0] nhead_cor[0:1];
    reg[10:0] nbody_cor[0:399];
    reg[10:0] napple_cor[0:399];

    snake_logic(
        .head_cor(shead_cor),
        .body_cor(sbody_cor),
        .apple_cor(apple_cor),
        .icar(char_i),
        .nh_c(nhead_cor),
        .nb_c(nbody_cor),
        .na_c(napple_cor)
    );

    initial begin
        file_o=$fopen("../output.txt","r");
        if (file_o==0) begin
            $display("file not found");
        end
        else begin
            while(!$feof(file_o)) begin
                char=$fgetc(file_o);
                if(char=="\n") begin
                    #1;
                    if (flag == 1) begin
                        i++;
                    end
                    j=0;
                    flag = 1;
                end else if(char==".") begin
                    board[i][j]=0;
                    j++;
                end else if(char=="S") begin
                    board[i][j]=1;
                    j++;
                end else if(char=="H") begin
                    board[i][j]=2;
                    j++;
                end else if(char=="A") begin
                    board[i][j]=3;
                    j++;
                end
            end
        end
        $fclose(file_o);

        for (integer row = 0; row <= 19; row = row + 1) begin
            for (integer col = 0; col <= 19; col = col + 1) begin
                $write("%0d ", board[row][col]); // Print each element in a row
            end
            $write("\n"); // Newline after each row
        end

        file_i=$fopen("../input.txt","r");
        while(!$feof(file_i)) begin
            char_i=$fgetc(file_i);
        end
        $fclose(file_i);

        file_i=$fopen("../input.txt","w");
        $fclose(file_i);

        for(row=0;row<=19;row++) begin
            for(col=0;col<=19;col++) begin
                if(board[row][col]==3) begin
                    apple_cor[0]=row;
                    apple_cor[1]=col;
                end if(board[row][col]==2) begin
                    shead_cor[0]=row;
                    shead_cor[1]=col;
                end if(board[row][col]==1) begin
                    sbody_cor[ref_sbody]=row;
                    ref_sbody++;
                    sbody_cor[ref_sbody]=col;
                    ref_sbody++;
                end
            end
        end

        for(row=0;row<=19;row++) begin
            for(col=0;col<=19;col++) begin
                board[row][col]=0;
            end
        end

        board[nhead_cor[0]][nhead_cor[1]]=2;
        board[napple_cor[0]][napple_cor[1]]=3;
        i=0;
        j=i+1;
        while (nbody_cor[i]!=" ") begin
            board[nbody_cor[i]][nbody_cor[j]]=1;
            i=i+2;
        end

        for(row=0;row<=21;row++) begin
            for(col=0;col<=21;col++) begin
                if(row==0 || row==21) begin
                    nboard[row][col]="-";
                end else if(col==0 || col==21) begin
                    if(row==0 || row==21) begin
                        nboard[row][col]="-";
                    end else begin
                        nboard[row][col]="|"; 
                    end
                end else begin
                    nboard[row][col]=board[row-1][col-1];
                end
            end
        end

        file_o=$fopen("output.txt","w");
        for(row=0;row<=21;row++) begin
            for(col=0;col<=21;col++) begin
                $fwrite(file_o,"%c",nboard[row][col]);
            end
            $fwrite(file_o,"\n");
        end
        $fclose(file_o);
    end
endmodule
