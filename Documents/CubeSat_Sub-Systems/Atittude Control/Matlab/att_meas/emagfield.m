                function [Hn,dipA,decA] = emagfield(lat,lon,h)
%----------------------------------------------------------------------
%               function [Hn,dipA,decA] = emagfield(lat,lon,h)
%
%   Wrapper around IGRF magnetic field computation routines that takes
%   the geodetic coordinates latitude (lat), longitude (lon) and
%   altitude (h), and returns the earth's magnetic field vector (Hn) 
%   in Tesla (= 1e+04 Gauss) coordinatized in NED coordinates, the dip 
%   angle (dipA) in radians and the declenation/variation angle (decA)
%   in radians at that location.
%
%   This is a wrapper around the NASA Langley igrf m_files by
%   Carlor Roithmayr.
%
%
%   Demoz Gebre-Egziabher
%   Last modified 4/7/00 
%---------------------------------------------------------------------

ecef = lla2ecef([lat,lon,h]);
ecef = ecef/1000;

[G,H] = IGRF95;               % IGRF coefficients for 1995

nmax = 10;                    % max degree of geopotential
mmax = 10;                    % max order  of geopotential

Kschmidt = schmidt(nmax,mmax);

[A,ctilde,stilde] = recursion(ecef',nmax,mmax);
Hn_ecef = bfield(ecef',nmax,mmax,Kschmidt,A,ctilde,stilde,G,H);

Hn = ecef2ned2(Hn_ecef,1000*ecef);
dipA = atan(Hn(3)/Hn(1));
decA = atan(Hn(2)/Hn(1));

%==========================================================================%
function bepe = bfield(repe,nmax,mmax,K,A,ctilde,stilde,G,H)


%+=====================================================================+
%
%     Programmers:  Carlos Roithmayr                           Feb 1997
%
%                   NASA Langley Research Center
%                   Spacecraft and Sensors Branch (CBC)
%                   757 864 6778
%                   c.m.roithmayr@larc.nasa.gov
%
%+---------------------------------------------------------------------+
%
%     Purpose:
%
%     Compute magnetic field exerted at a point P.
%
%+---------------------------------------------------------------------+
%
%     Argument definitions:
%
%     repe    (km)      Position vector from Earth's center, E*, to a
%                       point, P, expressed in a basis fixed in the
%                       Earth (ECF): 1 and 2 lie in equatorial plane
%                       with 1 in the plane containing the prime
%                       meridian, in the direction of the north pole.
%
%     nmax              Maximum degree of contributing spherical harmonics
%
%     mmax              Maximum order of contributing spherical harmonics
%
%     K                     coefficients that relate Schmidt functions to
%                                               associated Legendre functions.
%
%     A                 Derived Legendre polynomials
%
%     ctilde            See pp. 4--9 of Ref. [1]
%
%     stilde            See pp. 4--9 of Ref. [1]
%
%     G, H     Tesla    Schmidt-normalized Gauss coefficients
%
%     R_mean   km       Mean radius for International Geomagnetic
%                       Reference Field (6371.2 km)
%
%     bepe     Tesla    Magnetic field at a point, P, expressed in ECF
%                       basis
%
%+---------------------------------------------------------------------+
%
%     References:
%
%     1. Mueller, A. C., "A Fast Recursive Algorithm for Calculating
%        the Forces Due to the Geopotential", NASA JSC Internal Note
%        No. 75-FM-42, June 9, 1975.
%
%     2. Roithmayr, C., "Contributions of Spherical Harmonics to
%        Magnetic and Gravitational Fields", EG2-96-02, NASA Johnson
%        Space Center, Jan. 23, 1996.
%
%+---------------------------------------------------------------------+
%
%     Conversion factors:
%
%       1 Tesla = 1 Weber/(meter-meter) = 1 Newton/(Ampere-meter)
%               = 1e+4 Gauss  =  1e+9 gamma
%
%+=====================================================================+

% The number 1 is added to degree and order since MATLAB can't have an array
% index of 0.

R_mean = 6371.2;              % Mean radius for International Geomagnetic
                              % Reference Field (6371.2 km)
e1=[1 0 0];
e2=[0 1 0];
e3=[0 0 1];

rmag = sqrt(repe*repe');
rhat = repe/rmag;

u = rhat(3);                    % sin of latitude

bepe = [0 0 0];

% Seed for recursion formulae

scalar = R_mean*R_mean/(rmag*rmag);

for n = 1:nmax

% Recursion formula
  scalar = scalar*R_mean/rmag;


  i=n+1;

  for m = 0:n

    j=m+1;

    if m <= mmax
      ttilde(i,j) = G(i,j)*ctilde(j) + H(i,j)*stilde(j);

%     ECF 3 component {Eq. (2), Ref. [2]}
      b3(i,j) =  -ttilde(i,j)*A(i,j+1);

%     rhat component {Eq. (2), Ref. [2]}
      br(i,j) = ttilde(i,j)*(u*A(i,j+1) + (n+m+1)*A(i,j));

%     Contribution of zonal harmonic of degree n to magnetic
%     field.  {Eq. (2), Ref. [2]}

      bepe = bepe + scalar*K(i,j)*(b3(i,j)*e3 + br(i,j)*rhat);
    end

    if ((m > 0) & (m <= mmax))

%     ECF 1 component {Eq. (2), Ref. [2]}
      b1(i,j) = -m*A(i,j)*(G(i,j)*ctilde(j-1) + H(i,j)*stilde(j-1));

%     ECF 2 component {Eq. (2), Ref. [2]}
      b2(i,j) = -m*A(i,j)*(H(i,j)*ctilde(j-1) - G(i,j)*stilde(j-1));

%     Contribution of tesseral harmonic of degree n and order m to
%     magnetic field.  {Eq. (2), Ref. [2]}
      bepe = bepe + scalar*K(i,j)*(b1(i,j)*e1 + b2(i,j)*e2);
    end

  end
end
%======================================================================%


function [A,ctilde,stilde] = recursion(repe,nmax,mmax)

%+=====================================================================+
%
%     Programmers:  Carlos Roithmayr                            Dec 1995
%
%                   NASA Langley Research Center
%                   Spacecraft and Sensors Branch (CBC)
%                   757 864 6778
%                   c.m.roithmayr@larc.nasa.gov
%
%+---------------------------------------------------------------------+
%
%     Purpose:
%
%     Recursive calculations of derived Legendre polynomials and other
%     quantities needed for gravitational and magnetic fields.
%
%+---------------------------------------------------------------------+
%
%     Argument definitions:
%
%     repe    (m?)      Position vector from Earth's center, E*, to a
%                       point, P, expressed in a basis fixed in the
%                       Earth (ECF): 1 and 2 lie in equatorial plane
%                       with 1 in the plane containing the prime meridian,
%                       3 in the direction of the north pole.
%                       The units of length are not terribly important,
%                       since repe is made into a unit vector.
%
%     nmax              Maximum degree of derived Legendre polynomials
%
%     mmax              Maximum order of derived Legendre polynomials
%
%     A                 Derived Legendre polynomials
%
%     ctilde            See pp. 4--9 of Ref. [1]
%
%     stilde            See pp. 4--9 of Ref. [1]
%
%+---------------------------------------------------------------------+
%
%     References:
%
%     1. Mueller, A. C., "A Fast Recursive Algorithm for Calculating
%        the Forces Due to the Geopotential", NASA JSC Internal Note
%        No. 75-FM-42, June 9, 1975.
%
%     2. Lundberg, J. B., and Schutz, B. E., "Recursion Formulas of
%        Legendre Functions for Use with Nonsingular Geopotential
%        Models", Journal of Guidance, Control, and Dynamics, Vol. 11,
%        Jan--Feb 1988, pp. 32--38.
%
%+=====================================================================+

% The number 1 is added to degree and order since MATLAB can't have an
% array index of 0.

clear A;
A=zeros(nmax+3,nmax+3);         % A(n,m) = 0, for m > n

R_m = sqrt(repe*repe');
rhat = repe/R_m;

u = rhat(3);                    % sin of latitude

A(1,1)=1;                       % "derived" Legendre polynomials
A(2,1)=u;
A(2,2)=1;
     clear ctilde
     clear stilde
ctilde(1) = 1; ctilde(2) = rhat(1);
stilde(1) = 0; stilde(2) = rhat(2);

for n = 2:nmax
  i=n+1;

% Calculate derived Legendre polynomials and "tilde" letters
% required for gravitational and magnetic fields.

% Eq. (4a), Ref. [2]
  A(i,i) = prod(1:2:(2*n - 1));

% Eq. (4b), Ref. [2]
  A(i,(i-1))= u*A(i,i);

  if n <= mmax
%   p. 9,     Ref. [1]
    ctilde(i)  = ctilde(2) * ctilde(i-1) - stilde(2) * stilde(i-1);
    stilde(i)  = stilde(2) * ctilde(i-1) + ctilde(2) * stilde(i-1);
  end

  for m = 0:n
    j=m+1;


    if (m < (n-1)) & (m <= (mmax+1))
%     Eq. I, Table 1, Ref. [2]
      A(i,j)=((2*n - 1)*u*A((i-1),j) - (n+m-1)*A((i-2),j))/(n-m);
    end

  end
end
%======================================================================
function K = schmidt(nmax,mmax)

%+=====================================================================+
%
%     Programmers:  Carlos Roithmayr                            Feb 1997
%
%                   NASA Langley Research Center
%                   Spacecraft and Sensors Branch (CBC)
%                   757 864 6778
%                   c.m.roithmayr@larc.nasa.gov
%
%+---------------------------------------------------------------------+
%
%     Purpose:
%
%     Compute coefficients that relate Schmidt functions to associated
%     Legendre functions.
%
%+---------------------------------------------------------------------+
%
%     Argument definitions:
%
%     nmax              Maximum degree of contributing spherical harmonics
%
%     mmax              Maximum order of contributing spherical harmonics
%
%     K                     coefficients that relate Schmidt functions to
%                           associated Legendre functions (Ref. [1]).
%
%+---------------------------------------------------------------------+
%
%     References:
%
%     1. Haymes, R. C., Introduction to Space Science, Wiley, New
%        York, 1971.
%
%     2. Roithmayr, C., "Contributions of Spherical Harmonics to
%        Magnetic and Gravitational Fields", EG2-96-02, NASA Johnson
%        Space Center, Jan. 23, 1996.
%
%+=====================================================================+

% The number 1 is added to degree and order since MATLAB can't have an array
% index of 0.


% Seed for recursion formulae
K(2,2) = 1;

% Recursion formulae

for n = 1:nmax
    i=n+1;

  for m = 0:n
     j=m+1;

    if m == 0
        % Eq. (3), Ref. [2]
          K(i,j) = 1;

        elseif ((m >= 1) & (n >= (m+1)))
    % Eq. (4), Ref. [2]
          K(i,j) = sqrt((n-m)/(n+m))*K(i-1,j);

        elseif ((m >= 2) & (n >= m))
    % Eq. (5), Ref. [2]
          K(i,j) = K(i,j-1)/sqrt((n+m)*(n-m+1));
        end

  end
end

%==================================================================

function [G,H] = IGRF95

% MATLAB routine to load Schmidt-normalized coefficients
% retrieved from ftp://nssdc.gsfc.nasa.gov/pub/models/igrf/

% igrf95.dat                  1 Kb    Mon Nov 13 00:00:00 1995

% ? C.E. Barton, Revision of International Geomagnetic Reference
% Field Released, EOS Transactions 77, #16, April 16, 1996.


% The coefficients are from the 1995 International Geomagnetic Reference Field

% Carlos Roithmayr, Jan. 22, 1997.

%++++++++++++++++++++++++++++++++++++++++++

% The number 1 is added to ALL subscripts since MATLAB can't have an array
% index of 0.  Units of Tesla

G(2,1) = -29682e-9;
G(2,2) = -1789e-9; H(2,2) =  5318e-9;
G(3,1) = -2197e-9; H(3,1) =     0.0;
G(3,2) =  3074e-9; H(3,2) =   -2356e-9;
G(3,3) =  1685e-9; H(3,3) =  -425e-9;
G(4,1) =  1329e-9; H(4,1) =     0.0;
G(4,2) = -2268e-9; H(4,2) =  -263e-9;
G(4,3) =  1249e-9; H(4,3) =   302e-9;
G(4,4) =   769e-9; H(4,4) =  -406e-9;
G(5,1) =   941e-9; H(5,1) =      .0;
G(5,2) =   782e-9; H(5,2) =   262e-9;
G(5,3) =   291e-9; H(5,3) =  -232e-9;
G(5,4) =  -421e-9; H(5,4) =    98e-9;
G(5,5) =   116e-9; H(5,5) =  -301e-9;
G(6,1) =  -210e-9; H(6,1) =      .0;
G(6,2) =   352e-9; H(6,2) =    44e-9;
G(6,3) =   237e-9; H(6,3) =   157e-9;
G(6,4) =  -122e-9; H(6,4) =  -152e-9;
G(6,5) =  -167e-9; H(6,5) =   -64e-9;
G(6,6) =   -26e-9; H(6,6) =    99e-9;
G(7,1) =    66e-9; H(7,1) =      .0;
G(7,2) =    64e-9; H(7,2) =   -16e-9;
G(7,3) =    65e-9; H(7,3) =    77e-9;
G(7,4) =  -172e-9; H(7,4) =    67e-9;
G(7,5) =     2e-9; H(7,5) =   -57e-9;
G(7,6) =    17e-9; H(7,6) =     4e-9;
G(7,7) =   -94e-9; H(7,7) =    28e-9;
G(8,1) =    78e-9; H(8,1) =     -.0;
G(8,2) =   -67e-9; H(8,2) =   -77e-9;
G(8,3) =     1e-9; H(8,3) =   -25e-9;
G(8,4) =    29e-9; H(8,4) =     3e-9;
G(8,5) =     4e-9; H(8,5) =    22e-9;
G(8,6) =     8e-9; H(8,6) =    16e-9;
G(8,7) =    10e-9; H(8,7) =   -23e-9;
G(8,8) =    -2e-9; H(8,8) =    -3e-9;
G(9,1) =    24e-9; H(9,1) =      .0;
G(9,2) =     4e-9; H(9,2) =    12e-9;
G(9,3) =    -1e-9; H(9,3) =   -20e-9;
G(9,4) =    -9e-9; H(9,4) =     7e-9;
G(9,5) =   -14e-9; H(9,5) =   -21e-9;
G(9,6) =     4e-9; H(9,6) =    12e-9;
G(9,7) =     5e-9; H(9,7) =    10e-9;
G(9,8) =     0e-9; H(9,8) =   -17e-9;
G(9,9) =    -7e-9; H(9,9) =   -10e-9;
G(10,1) =     4e-9; H(10,1) =      .0;
G(10,2) =     9e-9; H(10,2) =   -19e-9;
G(10,3) =     1e-9; H(10,3) =    15e-9;
G(10,4) =   -12e-9; H(10,4) =    11e-9;
G(10,5) =     9e-9; H(10,5) =    -7e-9;
G(10,6) =    -4e-9; H(10,6) =    -7e-9;
G(10,7) =    -2e-9; H(10,7) =     9e-9;
G(10,8) =     7e-9; H(10,8) =     7e-9;
G(10,9) =     0e-9; H(10,9) =    -8e-9;
G(10,10) =    -6e-9; H(10,10) =     1e-9;
G(11,1) =    -3e-9; H(11,1) =      .0;
G(11,2) =      -4e-9; H(11,2) =     2e-9;
G(11,3) =       2e-9; H(11,3) =     1e-9;
G(11,4) =      -5e-9; H(11,4) =     3e-9;
G(11,5) =      -2e-9; H(11,5) =     6e-9;
G(11,6) =       4e-9; H(11,6) =    -4e-9;
G(11,7) =       3e-9; H(11,7) =     0.;
G(11,8) =       1e-9; H(11,8) =    -2e-9;
G(11,9) =       3e-9; H(11,9) =     3e-9;
G(11,10) =      3e-9; H(11,10) =    -1e-9;
G(11,11) =      0e-9; H(11,11) =    -6e-9;

