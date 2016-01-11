function [gx,gy]=GaussGradient(IM,sigma)
%GAUSSGRADIENT Gradient using first order derivative of Gaussian.
%  [gx,gy]=GaussGradient(IM,sigma) outputs the gradient image gx and gy of
%  image IM using a 2-D Gaussian kernel. Sigma is the standard deviation of
%  this kernel along both directions.
%
%  Contributed by Guanglei Xiong (xgl99@mails.tsinghua.edu.cn)
%  at Tsinghua University, Beijing, China.

%determine the appropriate size of kernel. The smaller epsilon, the larger
%radius.
%epsilon=1e-2;
%radius=ceil(sigma*sqrt(-2*log(sqrt(2*pi)*sigma*epsilon)))
radius=2;
size=2*radius+1;
%generate a 2-D Gaussian kernel along x direction
for i=1:size
    for j=1:size
        u=[i-radius-1 j-radius-1];
        hx(i,j)=gauss(u(1),sigma)*dgauss(u(2),sigma);
    end
end
hx=hx/sqrt(sum(sum(abs(hx).*abs(hx))));
%generate a 2-D Gaussian kernel along y direction
hy=hx';
%2-D filtering
gx=imfilter(IM,hx,'replicate','conv');
gy=imfilter(IM,hy,'replicate','conv');

function y = gauss(x,sigma)
%Gaussian
y = exp(-x^2/(2*sigma^2)) / (sigma*sqrt(2*pi));

function y = dgauss(x,sigma)
%first order derivative of Gaussian
y = -x * gauss(x,sigma) / sigma^2;