function function_chain=addToFunctionChain(function_chain,new_function)
%CellAnimation core function. Used to add a module to the function chain 

function_chain=[function_chain;{new_function}];

%end addToFunctionChain
end