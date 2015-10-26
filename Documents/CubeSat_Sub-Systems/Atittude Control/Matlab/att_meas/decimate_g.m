function [x_decimated]=decimate_g(x_g,WINDOW_WIDTH);
    dim =floor(length(x_g)/WINDOW_WIDTH);
    x_shapeshifted = reshape(x_g(1:dim*WINDOW_WIDTH),WINDOW_WIDTH,dim);
    x_decimated = (mean(x_shapeshifted))';
