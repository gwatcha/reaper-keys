local t = {}

function t.tableConcat(t1,t2)
  for i=1,#t2 do
    t1[ #t1+1 ] = t2[i]  --corrected bug. if t1[#t1+i] is used, indices will be skipped
  end
  return t1
end


return t
