
function bloader(filename as string, x as integer, y as integer) as fb.image ptr
  dim as integer ff = freefile(), bwidth, bheight
  dim as fb.image ptr res, temp
  
  Open filename For Binary As #ff
  Get #ff, 19, bwidth
  Get #ff, 23, bheight
  Close #ff
  
  temp = imagecreate(bwidth, bheight)
  bload(filename, temp)
  
  res = imagecreate(x, y, &HFF000000)
  put res, ((x - bwidth) \ 2, (y - bheight) \ 2), temp, pset
  imagedestroy(temp)
  
  return res
end function
