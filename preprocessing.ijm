// Process Virtual Stack
//
// This macro demonstrates how to process the images in a
// virtual stack, save the processed images in a folder, and
// then open those images in another virtual stack. The virtual
// stack can be opened using File>Import>Image Sequence,
// File>Import>TIFF Virtual Stack or File>Import>Raw.

  if (nSlices==1) exit("Stack required");
  dir = getDirectory("Choose Destination Directory ");
  setBatchMode(true);
  id = getImageID;
  for (i=1; i<= nSlices; i++) {
      showProgress(i, nSlices);
      selectImage(id);
      setSlice(i);
      name = getMetadata;
      run("Duplicate...", "title=temp");

      run("8-bit");
	  run("Set Scale...", "distance=0 known=0 unit=pixel");
	  run("Enhance Contrast", "saturated=0.35 normalize");
      saveAs("tif", dir+pad(i-1));
      close();
  }
  setBatchMode(false);
  
  run("Image Sequence...", "open=["+dir+"0000.tif] use");

  function pad(n) {
      str = toString(n);
      while (lengthOf(str)<6)
          str = "0" + str;
      return str;
  }