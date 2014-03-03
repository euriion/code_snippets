tt <-
  '<x>
  <a>text</a>
  <b>bbb</b>
  <c bar="me" />
  <d>a phrase</d>
  <e>
   <e1>aa1</e1>
   <e2>bb1</e2>
   <e3>cc1</e3>
  </e>
  <e>
   <e1>aa2</e1>
   <e2>bb2</e2>
   <e3>cc2</e3>
  </e>  
  </x>'
doc <- xmlInternalTreeParse(tt)
xmlToDataFrame(getNodeSet(doc, "//x/e")) # select all children of e node
xmlToDataFrame(getNodeSet(doc, "//x/e/*[self::e1 or self::e2]"))  # select e1 and e2 vertically
