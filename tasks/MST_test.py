"""
    fMRI 97 - Test Phase - Not scanned
    Participants are presented with objects and scenes: Old targets, similar lures, or novel images
    Make Old, Similar, New judgements:
        500 ms red fixaton; 2000 ms image presentation; 2000 ms white fixation
    Created in PsychoPy version v2020.2.10; Last edit: 4/6/2021
"""

# Import modules
from __future__ import absolute_import, division
from psychopy import locale_setup, prefs, sound, gui, visual, core, data, event, logging, clock, monitors
import os, sys, time, csv, math
from datetime import datetime
from psychopy.hardware import keyboard
import collections # to handle ordereddict
now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

# Setup directory relative to the experiment file
RootDir = os.path.dirname(os.path.abspath(__file__))
ImgDir = RootDir + '\\images\\'
StimDir = RootDir + '\\stimlists\\'
DataDir = RootDir + '\\data\\'
SchemaDir = RootDir + '\\schemas\\'
os.chdir(RootDir)

# Get experiment information
expName = 'fmri97_test' 
expInfo = {'Participant': '', 'Stimlist': '', 'Counterbalance': '', 'TestBlock': ''}
dlg = gui.DlgFromDict(dictionary=expInfo, sortKeys=False, title=expName)
if dlg.OK == False:
    core.quit()  
    
# Prepare Files
filename = DataDir +  '%s_%s_%s' % (expName, expInfo['Participant'], expInfo['TestBlock'])
logFile = logging.LogFile(filename +'.log', level=logging.INFO) # what goes into logfile, start with info
logging.console.setLevel(logging.WARNING) # what goes into console, keep warnings and errors
thisExp = data.ExperimentHandler(name=expName, savePickle=True, saveWideText=True, dataFileName=filename)

# Define stimlist and trials 
TestBlock = int(expInfo['TestBlock'])
start = (TestBlock - 1) * 109
end = (TestBlock) * 109

stimfile = os.path.join(StimDir, 'fmri97_TestList_{}.csv'.format(expInfo['Stimlist']))
logging.log(level=logging.INFO, msg = expInfo) # Save on top of logfile

# Set Counterbalance
if expInfo['Counterbalance'] == '1' or expInfo['Counterbalance'] == '3':
    cues_txt = 'O   S   N'
    schemapic = SchemaDir + 'fmri97_test_schema_CBs13.PNG'
elif expInfo['Counterbalance'] == '2' or expInfo['Counterbalance'] == '4':
    cues_txt = 'N   S   O'
    schemapic = SchemaDir + 'fmri97_test_schema_CBs24.PNG'

# Define Experiment components
win = visual.Window(size=(1920, 1080), fullscr=True, screen=1, winType='pyglet', allowGUI=False, allowStencil=False, 
    monitor='testMonitor', color=[0,0,0], colorSpace='rgb',blendMode='avg', useFBO=True, 
    units='height') # bottom left of the screen is (-0.8,-0.5) and top-right is (+0.8,+0.5); 1920x1080 consistent with scanner screen
    
bg = visual.Rect(win=win, name='bg',width=(2, 2)[0], height=(2, 2)[1], ori=0, pos=(0, 0),lineWidth=1, lineColor=[1,1,1], 
    lineColorSpace='rgb', fillColor=[0.07,0.07,0.07], fillColorSpace='rgb', opacity=1, depth=0.0, interpolate=True)
    
fix = visual.TextStim(win=win, name='fix', text='+', font='Arial', pos=(0, 0.15), height=0.05, 
    wrapWidth=None, ori=0, color='white', colorSpace='rgb', opacity=1, languageStyle='LTR', depth=-2.0)
    
text = visual.TextStim(win=win, name='text', text='default text', font='Arial', pos=(0, 0), height=0.05, 
    wrapWidth=None, ori=0, color='white', colorSpace='rgb', opacity=1, languageStyle='LTR', depth=-2.0)
    
img = visual.ImageStim(win=win, name='img', image='sin', mask=None, ori=0, pos=(0, 0.15), size=(0.237, 0.237),
    color=[1,1,1], colorSpace='rgb', opacity=1, flipHoriz=False, flipVert=False, texRes=128, interpolate=True, depth=-2.0)

schema = visual.ImageStim(win=win, name='schema', image= schemapic, mask=None, ori=0, pos=(0, 0), size=(0.9, 0.4),
    color=[1,1,1], colorSpace='rgb', opacity=1, flipHoriz=False, flipVert=False, texRes=128, interpolate=True, depth=-2.0)

cues = visual.TextStim(win=win, name='cue', text=cues_txt, font='Arial',pos=(0.2, -0.1), height=0.05, 
    wrapWidth=None, ori=0, color='white', colorSpace='rgb', opacity=1, languageStyle='LTR', depth=-7.0)


# Prepare timing of components
redFixTime = 0.5
imgTime = 2.0
cueTime = 4.0 
whiteFix = 2.0

# Set up timers and other
globalClock = core.Clock() # to track the time since experiment started
trialClock = core.Clock() # to track trial time
testResp = keyboard.Keyboard() # the actual response
escapekey = keyboard.Keyboard() # check for escape

# Prepare trial list
all_trials = data.TrialHandler(nReps=1, method='sequential', originPath=-1,
    trialList=data.importConditions(stimfile, selection = range(start,end)), 
    seed=None, name='trials')

# Prepare initial frames
bg.draw()
schema.draw()
win.flip()

# Start experiment
event.Mouse(visible=False)
start = event.waitKeys(keyList=['space'], clearEvents = True)
text.setText('Here we go!')
bg.draw()
text.draw()
win.flip()
core.wait(1)

# Go through trials
for trial in range(0,all_trials.nTotal):
    
    # Prepare trial components
    curTrial = all_trials.trialList[trial] # select trial
    Image = curTrial['img']
    img.setImage(ImgDir + Image) # Set give the Image variable in stimlist
    frameN1, frameN2 = 0, 0 
    
    # Clean up from last iteration
    testResp.keys = []
    testResp.rt = []
    testResp.clearEvents()
    trialClock.reset(newT=0.0) # Trial started, reset clock to zero.
    
    # Do trial stuff
    runTrial = True
    while runTrial: # start going frame-by-frame
        event.getKeys()
        t1 = trialClock.getTime() # to track trial times
        bg.draw() # run background with every frame
        
        # Red fixation
        if t1 >= 0.0 and t1 <= redFixTime: # Draw with every frame between 0.0 to redFixTime
            if frameN1 == 0: # only on the first frame 
                print('Trial #', trial+1) # for command window
                fix.setColor('red') # set fixation to red
                frameN1 = 1
            fix.draw()
            
        # Image
        if t1 >= redFixTime and t1 <= redFixTime + imgTime:
            img.draw()
    
            if frameN2 == 0: # only on the first frame of Image draw
                testResp.clearEvents() # clear keyboard
                testResp.clock.reset()  # Reset timer 
                frameN2 = 1
        
        # Responses, start tracking after red fixation until response cues are available
        if t1 >= redFixTime and t1 <= redFixTime + cueTime:
            curResp = testResp.getKeys(keyList=['1', '2', '3', '4', '6', '7', '8', '9'], waitRelease=False)
            quit = escapekey.getKeys(keyList=['escape'], waitRelease=False)
            if len(curResp):
                curResp = curResp[0]
                testResp.keys.append(curResp.name)
                testResp.rt.append(curResp.rt)

            if len(quit): #an escape button was pressed
                win.close(); 
                core.quit() # terminate 
        # Cues
        if t1 >= redFixTime and t1 <= redFixTime + cueTime:
            cue.draw()

        # White fixation
        if t1 >= redFixTime + imgTime:
            if frameN1 == 1: # only on the first frame, to keep logfile readable
                fix.setColor('white')
                frameN1 = 2
            fix.draw()
        
        # Is it time to end the trial or do we flip the window?
        if t1 > redFixTime + cueTime:
            runTrial = False
        win.flip()
            
    # Log what happened during the trial
    trial_info = list(curTrial.items()) # for stimlist info
    for col in trial_info:
        a, b = col
        thisExp.addData(a, b)
    if testResp.keys in ['', [], None]:  # No response was made
        testResp.keys = None
        print('No response!')
    thisExp.addData('response',testResp.keys)
    if testResp.keys != None:  
        thisExp.addData('RT', testResp.rt)
    thisExp.nextEntry()
    
# Finished all trials
text.setText('End of Block')
endTime = globalClock.getTime() + 4
while globalClock.getTime() < endTime:
    bg.draw()
    if globalClock.getTime() < endTime - 2:
        fix.draw()
    else: 
        text.draw()
    win.flip()

win.close()
core.quit()

