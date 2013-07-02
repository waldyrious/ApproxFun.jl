module Funs
    using Base, Winston

export IFun,Interval,evaluate,values,points,chebyshev_transform



####
# helper routines
####


alternating_vector(n::Integer) = 2*mod([1:n],2)-1;

function chebyshev_transform(x::Vector)
    ret = FFTW.r2r(x, FFTW.REDFT00);
    ret[1] *= .5;
    ret[end] *= .5;    
    ret.*alternating_vector(length(ret))/(length(ret)-1)
end

function ichebyshev_transform(x::Vector)
    x[1] *= 2;
    x[end] *= 2;
    
    ret = chebyshev_transform(x);
    
    x[1] *= .5;
    x[end] *= .5;
    
    ret[1] *= 2;
    ret[end] *= 2;
    
    flipud(ret.*alternating_vector(length(ret)).*(length(x) - 1).*.5)
end

points(n)= cos(π*[n-1:-1:0]/(n-1))

# points(d::Interval,n) = (d == [-1,1]) ? points(n) : points(n)



######
# IFun
#####


type IFun
    coefficients::Vector
    domain
end



function IFun(f::Function,n::Integer)
    IFun(chebyshev_transform(f(points(n))),[-1,1])
end


function evaluate(f::IFun,x)
    evaluate(f.coefficients,x)
end

function evaluate(v::Vector{Float64},x::Real)
    unp = 0.;
    un = v[end];
    n = length(v);
    for k = n-1:-1:2
        uk = 2.*x.*un - unp + v[k];
        unp = un;
        un = uk;
    end

    uk = 2.*x.*un - unp + 2*v[1];
    .5*(uk -unp)
end



function values(f::IFun)
   ichebyshev_transform(f.coefficients) 
end

function points(f::IFun)
    points(length(f))
end

function Base.length(f::IFun)
    length(f.coefficients)
end

function Winston.plot(f::IFun)
    plot(points(f),values(f))
end


end #module
