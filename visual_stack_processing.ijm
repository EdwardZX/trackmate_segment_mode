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
      run("Median...", "radius=1 slice");
      run("Unsharp Mask...", "radius=1 mask=0.60 slice");
      saveAs("tif", dir+pad(i-1));
      close();
  }
  setBatchMode(false);
  run("Image Sequence...", "open=["+dir+"00000.tif] use");

  function pad(n) {
      str = toString(n);
      while (lengthOf(str)<5)
          str = "0" + str;
      return str;
  }