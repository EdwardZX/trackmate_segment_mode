from ij import IJ
from ij.io import FileSaver
from os import path


imp = IJ.getImage()
fs = FileSaver(imp)

# check whether rewrite the picture
#folder = "E:/Phd_1_Spring/labcode/imageJ/data/fiji-tutorial"
folder = './data/fiji-tutorial'
if path.exists(folder) and path.isdir(folder):
	print 'folder exist:', folder
	filepath = path.join(folder,'sample.tif')
	if path.exists(filepath):
		print 'File exists! Not saving the image, would overwirte a file!'
	elif fs.saveAsTiff(filepath):
		print 'File saved successfully at ', filepath
else:
	print "Folder does not exist or it's not a folder" 
	#... such as mkdir or something else
 