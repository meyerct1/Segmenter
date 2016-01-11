function output_args=divideFunction(input_args)
%Usage
%This module divides two variables.
%
%Input Structure Members
%Var1 - The variable to be divided.
%Var2 - The divisor.
%ConvertToDouble - Boolean value. If true the variables are first converted
%to doubles.
%
%Output Structure Members
%Quotient - The result of the division.

var1=input_args.Var1.Value;
var2=input_args.Var2.Value;

if (input_args.ConvertToDouble.Value)
    output_args.Quotient=double(var1)./double(var2);
else
    output_args.Quotient=var1./var2;
end

%end addFunction
end