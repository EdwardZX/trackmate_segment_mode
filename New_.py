import sys
 
from ij import IJ
from ij import WindowManager
 
from fiji.plugin.trackmate import Model
from fiji.plugin.trackmate import Settings
from fiji.plugin.trackmate import TrackMate
from fiji.plugin.trackmate import SelectionModel
from fiji.plugin.trackmate import Logger
from fiji.plugin.trackmate.detection import LogDetectorFactory
from fiji.plugin.trackmate.tracking import LAPUtils
from fiji.plugin.trackmate.tracking.sparselap import SparseLAPTrackerFactory
from fiji.plugin.trackmate.providers import SpotAnalyzerProvider
from fiji.plugin.trackmate.providers import EdgeAnalyzerProvider
from fiji.plugin.trackmate.providers import TrackAnalyzerProvider
import fiji.plugin.trackmate.visualization.hyperstack.HyperStackDisplayer as HyperStackDisplayer
import fiji.plugin.trackmate.features.FeatureFilter as FeatureFilter
    
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
settings.detectorFactory = LogDetectorFactory()
settings.detectorSettings = { 
    'DO_SUBPIXEL_LOCALIZATION' : True,
    'RADIUS' : 6,
    'TARGET_CHANNEL' : 1,
    'THRESHOLD' : 0.,
    'DO_MEDIAN_FILTERING' : False,
}  
    
# Configure spot filters - Classical filter on quality
filter1 = FeatureFilter('QUALITY', 1, True)
settings.addSpotFilter(filter1)
     
# Configure tracker - We want to allow merges and fusions
settings.trackerFactory = SparseLAPTrackerFactory()
settings.trackerSettings = LAPUtils.getDefaultLAPSettingsMap() # almost good enough
settings.trackerSettings['ALLOW_TRACK_SPLITTING'] = True
settings.trackerSettings['ALLOW_TRACK_MERGING'] = True
 
# Add ALL the feature analyzers known to TrackMate, via
# providers. 
# They offer automatic analyzer detection, so all the 
# available feature analyzers will be added. 
 
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
    
# Configure track filters - We want to get rid of the two immobile spots at 
# the bottom right of the image. Track displacement must be above 10 pixels.
    
filter2 = FeatureFilter('TRACK_DISPLACEMENT', 10, True)
settings.addTrackFilter(filter2)
    
    
#-------------------
# Instantiate plugin
#-------------------
    
trackmate = TrackMate(model, settings)
       
#--------
# Process
#--------
    
ok = trackmate.checkInput()
if not ok:
    sys.exit(str(trackmate.getErrorMessage()))
    
ok = trackmate.process()
if not ok:
    sys.exit(str(trackmate.getErrorMessage()))
    
       
#----------------
# Display results
#----------------
     
selectionModel = SelectionModel(model)
displayer =  HyperStackDisplayer(model, selectionModel, imp)
displayer.render()
displayer.refresh()
    
# Echo results with the logger we set at start:
model.getLogger().log(str(model))