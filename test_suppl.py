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