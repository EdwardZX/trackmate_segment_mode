
batch = 200;
tail = 20;
dir = getDirectory("Choose a Directory ");
list = getFileList(dir);
num = Math.ceil(list.length/batch);
for (i = 0; i < 1; i++) {	
	//add the tail turn
	if (i>0) {
		num_batch = batch + tail;
		start_index = i*batch+1-tail;}
    else {
		num_batch = batch;
		start_index = i*batch+1;
	}
	order = "open=" + dir +" "+
	"number=" + num_batch + " "+ 
	"starting="+ start_index + " "+
"increment=1 scale=100 file=tif";
run("Image Sequence...", order); //open the image sequence
//swap t and z
run("Properties...", "channels=1 slices=1 frames=" + nSlices+" " +
"pixel_width=1.0000 pixel_height=1.0000 voxel_depth=1.0000");
//run tracking 
//runMacro("\mymacros\\simple_particles_tracking.py");
//close();
	}






