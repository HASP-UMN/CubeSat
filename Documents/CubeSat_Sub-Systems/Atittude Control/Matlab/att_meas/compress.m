                   function N = compress(M,ROWS,COLUMNS)
%------------------------------------------------------------------
%                                                                   
%                  function N = compress(M,ROWS,COLUMNS)           
%                                                                  
%     compress takes a matrix M, and removes the rows and columns  
%     specifed in ROWS and COLUMNS and returns a compressed        
%     matrix N.
%
%     Demoz Gebre
%     2/11/00                                                             
%------------------------------------------------------------------

nr = length(ROWS);
nc = length(COLUMNS);
[r,c] = size(M);

rn = r - nr;
cn = c - nc;

N = zeros(rn,cn);

m = 1;

r2k = zeros(rn,1);

for k = 1:r
    idx = find(ROWS == k);
    if(isempty(idx))
        r2k(m) = k;
        m = m + 1;
    end
end

m = 1;

c2k = zeros(cn,1);


for k = 1:c
    idx = find(COLUMNS == k);
    if(isempty(idx))
        c2k(m) = k;
        m = m + 1;
    end
end

N = M(r2k',c2k');


