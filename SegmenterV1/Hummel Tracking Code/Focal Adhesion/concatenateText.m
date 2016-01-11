function output_args=concatenateText(input_args)
% Usage
% This module is used to cobine several pieces of text together to form a
% string. It can be used for example to generate an absolute path name from a
% directory name, a file name and an extension.
% Input Structure Members
% Text 1-10 – The text items to be combined. Text3-9 are optional.
% Output Structure Members
% String – The combined string.
string_out=[input_args.Text1.Value input_args.Text2.Value];
field_names=fieldnames(input_args);
if (max(strcmp(field_names,'Text3')))
    string_out=[string_out input_args.Text3.Value];
end
if (max(strcmp(field_names,'Text4')))
    string_out=[string_out input_args.Text4.Value];
end
if (max(strcmp(field_names,'Text5')))
    string_out=[string_out input_args.Text5.Value];
end
if (max(strcmp(field_names,'Text6')))
    string_out=[string_out input_args.Text6.Value];
end
if (max(strcmp(field_names,'Text7')))
    string_out=[string_out input_args.Text7.Value];
end
if (max(strcmp(field_names,'Text8')))
    string_out=[string_out input_args.Text8.Value];
end
if (max(strcmp(field_names,'Text9')))
    string_out=[string_out input_args.Text9.Value];
end

output_args.String=string_out;

end