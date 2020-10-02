function draw_grid(arr, row, col)
start.row = 5;
start.col = 1;

goal.row= 1;
goal.col = 5;

CreateGrid(row, col,start,goal)

for i = 1:row
    for j = 1:col
        switch arr(i,j)
            case 1 % east
                textToDraw = '\rightarrow';
                rotation = 0;
            case 2 % south
                textToDraw = '\downarrow';
                rotation = 0;
            case 3 % west
                textToDraw = '\leftarrow';
                rotation = 0;
            case 4 % north
               textToDraw = '\uparrow';
               rotation = 0;
           case 5 % hold
               textToDraw = 'o';
               rotation = 0;
           otherwise
              textToDraw = ' ';
               rotation = 0;
        end

        xsp = 1 / (col + 2);
        ysp = 1 / (row + 2);
        xcor = ((2*j + 1) / 2) * xsp;
        ycor = 1 - (((2*i + 1) / 2) * ysp);
        xcor = xcor - xsp/5;
        text(xcor, ycor, textToDraw, 'Rotation', rotation,'Color','red','FontSize',20)
    end
end