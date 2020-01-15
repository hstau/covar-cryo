function [ax ay az]=euler_from_matrix(M, axes)
       
%Return Euler angles from rotation matrix for specified axis sequence.

%    axes : One of 24 axis sequences as string or encoded tuple

%    Note that many Euler angle triplets can describe one matrix.

%    >>> R0 = euler_matrix(1, 2, 3, 'syxz')
%    >>> al, be, ga = euler_from_matrix(R0, 'syxz')
%    >>> R1 = euler_matrix(al, be, ga, 'syxz')
%    >>> numpy.allclose(R0, R1)
%    True
%    >>> angles = (4.0*math.pi) * (numpy.random.random(3) - 0.5)
%    >>> for axes in _AXES2TUPLE.keys():
%    ...    R0 = euler_matrix(axes=axes, *angles)
%    ...    R1 = euler_matrix(axes=axes, *euler_from_matrix(R0, axes))
%    ...    if not numpy.allclose(R0, R1): print(axes, "failed")


% axis sequences for Euler angles
NEXT_AXIS = [1, 2, 0, 1];
EPS=1e-10;

[firstaxis parity repetition frame] = AXES2TUPLE(axes);


i = firstaxis+1;
j = NEXT_AXIS(i+parity)+1;
k = NEXT_AXIS(i-parity+1)+1;

if repetition==1
    sy = sqrt(M(i, j)*M(i, j) + M(i, k)*M(i, k));
    if sy > EPS
        ax = atan2( M(i, j),  M(i, k));
        ay = atan2( sy,       M(i, i));
        az = atan2( M(j, i), -M(k, i));
    else
        ax = atan2(-M(j, k),  M(j, j));
        ay = atan2( sy,       M(i, i));
        az = 0.0;
    end
else
    y = sqrt(M(i, i)*M(i, i) + M(j, i)*M(j, i));
    if cy > EPS
        ax = atan2( M(k, j),  M(k, k));
        ay = atan2(-M(k, i),  cy);
        az = atan2( M(j, i),  M(i, i));
    else
        ax = atan2(-M(j, k),  M(j, j));
        ay = atan2(-M(k, i),  cy);
        az = 0.0;
    end
end
if parity == 1
    ax=-ax; ay=-ay; az=-az;
end
if frame == 1
    temp=ax; 
    ax=az; 
    az=temp;
end

ax=ax*180/pi;
ay=ay*180/pi;
az=az*180/pi;



%map axes strings to/from tuples of inner axis, parity, repetition, frame



function [firstaxis parity repetition frame] = AXES2TUPLE(axes)
    if(axes=='sxyz') 
        firstaxis=0; parity=0; repetition=0; frame=0;
    elseif(axes=='sxyx') 
        [firstaxis parity repetition frame]=[ 0 0 1 0];
    elseif(axes=='sxzy') 
        [firstaxis parity repetition frame]=[ 0 1 0 0];
    elseif(axes=='sxzx') 
        [firstaxis parity repetition frame]=[ 0 1 1 0];
    elseif(axes=='syzx') 
        [firstaxis parity repetition frame]=[ 1 0 0 0];
    elseif(axes=='syzy') 
        [firstaxis parity repetition frame]=[ 1 0 1 0];
    elseif(axes=='syxz') 
        [firstaxis parity repetition frame]=[ 1 1 0 0];
    elseif(axes=='syxy') 
        [firstaxis parity repetition frame]=[ 1 1 1 0];
    elseif(axes=='szxy') 
        [firstaxis parity repetition frame]=[ 2 0 0 0];
    elseif(axes=='szxz') 
        [firstaxis parity repetition frame]=[ 2 0 1 0];
    elseif(axes=='szyx') 
        [firstaxis parity repetition frame]=[ 2 1 0 0];
    elseif(axes=='szyz') 
        [firstaxis parity repetition frame]=[ 2 1 1 0];
    elseif(axes=='rzyx') 
        [firstaxis parity repetition frame]=[ 0 0 0 1];
    elseif(axes=='rxyx') 
        [firstaxis parity repetition frame]=[ 0 0 1 1];
    elseif(axes=='ryzx') 
        [firstaxis parity repetition frame]=[ 0 1 0 1];
    elseif(axes=='rxzx') 
        [firstaxis parity repetition frame]=[ 0 1 1 1];
    elseif(axes=='rxzy') 
        [firstaxis parity repetition frame]=[ 1 0 0 1];
    elseif(axes=='ryzy') 
        [firstaxis parity repetition frame]=[ 1 0 1 1];
    elseif(axes=='rzxy') 
        [firstaxis parity repetition frame]=[ 1 1 0 1];
    elseif(axes=='ryxy') 
        [firstaxis parity repetition frame]=[ 1 1 1 1];
    elseif(axes=='ryxz') 
        [firstaxis parity repetition frame]=[ 2 0 0 1];
    elseif(axes=='rzxz') 
        firstaxis=2; parity=0; repetition=1; frame=1;
    elseif(axes=='rxyz') 
        [firstaxis parity repetition frame]=[ 2 1 0 1];
    elseif(axes=='rzyz') 
        firstaxis=2; parity=1; repetition=1; frame=1;
    end     
   

