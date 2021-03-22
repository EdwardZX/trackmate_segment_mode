import sys,os
 
from ij import IJ
from ij import WindowManager
import java.io.File as File
 
from fiji.plugin.trackmate import Model
from fiji.plugin.trackmate import Settings
from fiji.plugin.trackmate import TrackMate
from fiji.plugin.trackmate import SelectionModel
from fiji.plugin.trackmate import Logger
from fiji.plugin.trackmate.detection import LogDetectorFactory,BlockLogDetectorFactory
from fiji.plugin.trackmate.tracking import LAPUtils
from fiji.plugin.trackmate.tracking.sparselap import SparseLAPTrackerFactory
from fiji.plugin.trackmate.tracking.oldlap import LAPTrackerFactory
from fiji.plugin.trackmate.providers import SpotAnalyzerProvider
from fiji.plugin.trackmate.providers import EdgeAnalyzerProvider
from fiji.plugin.trackmate.providers import TrackAnalyzerProvider
import fiji.plugin.trackmate.visualization.hyperstack.HyperStackDisplayer as HyperStackDisplayer
import fiji.plugin.trackmate.features.FeatureFilter as FeatureFilter
from fiji.plugin.trackmate.action import ExportTracksToXML


from ij.plugin import Macro_Runner
from ij.io import DirectoryChooser  


'''
this file is aim to processing the long sequence of images
'''

def track_single_batch(path,filename):	
	# Get currently selected image
	imp = WindowManager.getCurrentImage()
		# imp = IJ.openImage('https://fiji.sc/samples/FakeTracks.tif')
	imp.show()
	    
	    
		#----------------------------
		# Create the model object now
		#----------------------------
	    
		# Some of the parameters we configure below need to have
		# a reference to the model at creation. So we create an
		# empty model now.
	    
	model = Model()
	    
		# Send all messages to ImageJ log window.
	model.setLogger(Logger.IJ_LOGGER)
	    
	    
	       
		#------------------------
		# Prepare settings object
		#------------------------
	       
	settings = Settings()
	settings.setFrom(imp)
	       
		# Configure detector - We use the Strings for the keys
		#settings.detectorFactory = LogDetectorFactory()
	settings.detectorFactory = BlockLogDetectorFactory()
	print 
	settings.detectorSettings = { 
	    'DO_SUBPIXEL_LOCALIZATION' : True,
	   	'RADIUS' : 7.5,
	    'TARGET_CHANNEL' : 1,
	   	 'THRESHOLD' : 0.25,
	   	 'DO_MEDIAN_FILTERING' : False,
	   	 'NSPLIT': 3,
		}  
	    
	# Configure spot filters - Classical filter on quality
	filter1 = FeatureFilter('QUALITY', 0.1, True) # in higher SNR;
	settings.addSpotFilter(filter1)
	
	# Configure tracker - We want to allow merges and fusions
	settings.trackerFactory = SparseLAPTrackerFactory()
	#settings.trackerFactory = LAPTrackerFactory()
	settings.trackerSettings = LAPUtils.getDefaultLAPSettingsMap() # almost good enough
	settings.trackerSettings['ALLOW_TRACK_SPLITTING'] = True
	settings.trackerSettings['ALLOW_TRACK_MERGING'] = True
	settings.trackerSettings['LINKING_MAX_DISTANCE'] = 15.0
	settings.trackerSettings['GAP_CLOSING_MAX_DISTANCE']=15.0
	settings.trackerSettings['MAX_FRAME_GAP']= 5
	
	
	
	# feature
	
	spotAnalyzerProvider = SpotAnalyzerProvider()
	for key in spotAnalyzerProvider.getKeys():
	    print( key )
	    settings.addSpotAnalyzerFactory( spotAnalyzerProvider.getFactory( key ) )
	    
	edgeAnalyzerProvider = EdgeAnalyzerProvider()
	for  key in edgeAnalyzerProvider.getKeys():    	
	    print( key )
	    settings.addEdgeAnalyzer( edgeAnalyzerProvider.getFactory( key ) )
	    
	trackAnalyzerProvider = TrackAnalyzerProvider()
	for key in trackAnalyzerProvider.getKeys():
	    print( key )
	    settings.addTrackAnalyzer( trackAnalyzerProvider.getFactory( key ) )
	
	
	
		#filter2 = FeatureFilter('TRACK_DISPLACEMENT', 3, True)
		#settings.addTrackFilter(filter2)
	
		# processing
	trackmate = TrackMate(model, settings)
	ok = trackmate.checkInput()
	if not ok:
	    sys.exit(str(trackmate.getErrorMessage()))
	    
	try:
	    ok = trackmate.process()
	except:
	      IJ.log("Nothing detected")  
	else:
		selectionModel = SelectionModel(model)
		displayer =  HyperStackDisplayer(model, selectionModel, imp)
		displayer.render()
		displayer.refresh()
	    
	# Echo results with the logger we set at start:
		model.getLogger().log(str(model))  
		 
	save_path = os.path.join(path,'result')	
	if not os.path.exists(save_path):
		os.mkdir(save_path,0755)
	outFile = File(save_path,filename)
	ExportTracksToXML.export(model, settings, outFile)
	imp.close()   
			



'''
	file_name_set = sorted(os.listdir(path))
	first_path = os.path.join(path, file_name_set[0])
	imp = IJ.getImage(first_path)
	width = imp.width
	height = imp.height
	return width,height
'''	


def run_tracking(path):
    batch = 200
    tail = 20 
    file_list = sorted(os.listdir(path))
    num = len(file_list)/batch + 1
    print num
    num_batch = batch
    start_index = 1	
    for i in range(num):
        if (i>0):
            num_batch = batch + tail
            start_index = i*batch+1	-tail

	    	
        order = "open=" + path +" "+ "number=" + str(num_batch) + " "+ \
               "starting="+ str(start_index) + " "+ \
               "increment=1 scale=100 file=tif"
        IJ.run("Image Sequence...", order)
        imp = IJ.getImage() 
        tile_name = imp.getTitle()+'_' + str(start_index)+'-'+\
        str(start_index+num_batch-1)
        imp.setTitle(tile_name)
        slices = imp.getNSlices()
        # swap z and t
        IJ.run("Properties...", "channels=1 slices=1 frames=" \
        + str(slices)+" " +\
"       pixel_width=1.0000 pixel_height=1.0000 voxel_depth=1.0000");

        filename = 'exportModel_' + str(start_index)+'-'+\
        str(start_index+num_batch-1) + '.xml'
        track_single_batch(path,filename)
        
        print("%d / %d " %(i+1, num))
        
        
		
			
	
		
	
	


# Add ALL the feature analyzers known to TrackMate, via
# providers. 
# They offer automatic analyzer detection, so all the 
# available feature analyzers will be added. 
 

    
# Configure track filters - We want to get rid of the two immobile spots at 
# the bottom right of the image. Track displacement must be above 10 pixels.    
    
#-------------------
# main
#-------------------

#file_dir = getDirectory();
  
dc = DirectoryChooser("Choose a folder")  
folder = dc.getDirectory()  

#IJ.run()
run_tracking(folder)
#track_single_batch()