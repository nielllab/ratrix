function value = LUTlookup(LUT, key)
% returns the value specified by the given key in the LUT
% if LUT is empty, then just return the key (for convenience in compileDetailedRecords)
if ~isempty(LUT)
    value = LUT{key};
else
    value=key;
end

end % end function
