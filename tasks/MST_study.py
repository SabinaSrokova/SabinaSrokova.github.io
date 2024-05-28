"""
    fMRI 97 - Study Phase 
    Participants are presented with objects and scenes; four types of trials:
        study (to be tested), novel (first presentation), repeat of novel, lure of novel
    Task, make indoor/outdoor judgements during image presentation + white fix:
        500 ms red fixaton; 2000 ms image presentation; 2000 ms white fixation
    Psychopy v2021.1.3
"""

# Import modules
from __future__ import absolute_import, division
from psychopy import locale_setup, prefs, sound, gui, visual, core, data, event, logging, clock, monitors
import os, sys, time, csv, math, glob
from datetime import datetime
from psychopy.hardware import keyboard
import collections # to handle ordereddict
now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

# Setup directory relative to the experiment file
RootDir = os.path.dirname(os.path.abspath(__file__))
ImgDir = RootDir + "\\images\\"
StimDir = RootDir + "\\stimlists\\"
DataDir = RootDir + "\\data\\"
SchemaDir = RootDir + '\\schemas\\'
os.chdir(RootDir)

# Get experiment information
expName = 'fmri97_study' 
expInfo = {'Participant': '', 'Stimlist': '', 'Counterbalance': '', 'StudyBlock': ''}
dlg = gui.DlgFromDict(dictionary=expInfo, sortKeys=False, title=expName)
if dlg.OK == False:
    core.quit()  
    
# Double check the block that was selected 
all_files = glob.glob(DataDir + '*.csv') # get all csv files in the data folder
last_file = max(all_files, key=os.path.getctime) # get the latest file that was created
prac_substr = 'study_practice_' + expInfo['Participant'] # to check if practice was last
warn = False

# Check block
if int(expInfo['StudyBlock']) == 1: # enter 1 and practice wasnt last
    if prac_substr not in last_file:
        warn = True
elif int(expInfo['StudyBlock']) != 1: # entered 2-9
    if prac_substr in last_file: # entered 2-9 but practice was last
        warn = True
    else:  # entered 2-9 but unexpected block
        if int(last_file[-5])+1 !=  int(expInfo['StudyBlock']):
            warn = True

# Give warning if necessary
if warn:
    checkgui = gui.Dlg(title='Input Checker', labelButtonOK=' STOP ', labelButtonCancel=' Ignore ')
    if prac_substr in last_file:
        checkgui.addText('Last block was Practice')
    elif int(expInfo['StudyBlock']) != 1:
        checkgui.addText('Last block was: ' + last_file[-5])
    checkgui.addText('Entered block is: ' + expInfo['StudyBlock'])
    checkgui.show()
    if checkgui.OK: # if user pressed STOP
        core.quit() # otherwise continue if ignore was needed (e.g. block needed to be restarted)

# Prepare Files
filename = DataDir +  '%s_%s_%s' % (expName, expInfo['Participant'], expInfo['StudyBlock'])
logFile = logging.LogFile(filename +'.log', level=logging.INFO)
logging.console.setLevel(logging.WARNING) 
thisExp = data.ExperimentHandler(name=expName, savePickle=True, saveWideText=True, dataFileName=filename)


# Define stimlist and trials 
StudyBlock = int(expInfo['StudyBlock'])
start = (StudyBlock - 1) * 41
end = (StudyBlock) * 41

stimfile = os.path.join(StimDir, 'fmri97_StudyList_{}.csv'.format(expInfo['Stimlist']))
logging.log(level=logging.INFO, msg = expInfo) # Save on top of logfile

# Set Counterbalance
if expInfo['Counterbalance'] == '1' or expInfo['Counterbalance'] == '2':
    cues_txt = 'I   O'
    schemapic = SchemaDir + 'fmri97_study_schema_CBs12.PNG'
elif expInfo['Counterbalance'] == '3' or expInfo['Counterbalance'] == '4':
    cues_txt = 'O   I'
    schemapic = SchemaDir + 'fmri97_study_schema_CBs34.PNG'


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
    color=[1,1,1], colorSpace='rgb', opacity=1, flipHoriz=False, flipVert=False, texRes=128, interpolate=True, depth=-2.0) #0.237 ~= 256 pix for 1920x1080

schema = visual.ImageStim(win=win, name='schema', image=schemapic, mask=None, ori=0, pos=(0, 0), size=(0.9, 0.4),
    color=[1,1,1], colorSpace='rgb', opacity=1, flipHoriz=False, flipVert=False, texRes=128, interpolate=True, depth=-2.0)

cues = visual.TextStim(win=win, name='cue', text= cues_txt, font='Arial',pos=(0.15, -0.1), height=0.05, 
    wrapWidth=None, ori=0, color='white', colorSpace='rgb', opacity=1, languageStyle='LTR', depth=-7.0)


# Prepare timing of components, whitefix is defined in stimlist with Jitter
redFixTime = 0.5
imgTime = 2.0
cueTime = 4.0 

# Set up timers and other
globalClock = core.Clock() # to track the time since experiment started
startClock = core.Clock() # to track the time since triggers were received
trialClock = core.Clock() # to track trial time
studyResp = keyboard.Keyboard() # the actual response
escapekey = keyboard.Keyboard() # check for escape

# Prepare trial list
all_trials = data.TrialHandler(nReps=1, method='sequential', originPath=-1,
    trialList=data.importConditions(stimfile, selection = range(start,end)), 
    seed=None, name='trials')

# Prepare initial frames
bg.draw()
schema.draw()
win.flip()

# Wait for scanner
trigger1 = event.waitKeys(keyList=['5'], clearEvents = True)
print('trigger 1 received')
startClock.reset() # for onsets
trigger2 = event.waitKeys(keyList=['5'], clearEvents = True)
print('trigger 2 received')

# Start experiment
event.Mouse(visible=False)
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
    Jitter = curTrial['jitter']
    img.setImage(ImgDir + Image) # Set give the Image variable in stimlist
    # Useful stuff
    frameN1 = 0
    frameN2 = 0
    
    # Clean up from last iteration
    studyResp.keys, studyResp.rt, trial_onset, stimulus_onset = [], [], [], []
    trialClock.reset(newT=0.0) # Trial started, reset clock to zero.
    studyResp.clearEvents()
    
    # Do trial stuff
    runTrial = True
    while runTrial: # start going frame-by-frame
        event.getKeys() # throw all presses / triggers into logfile
        t1 = trialClock.getTime() # to track trial times
        t2 = startClock.getTime() # to track onsets
        bg.draw() # run background with every frame
        
        # Red fixation
        if t1 >= 0.0 and t1 <= redFixTime: # Draw with every frame between 0.0 to redFixTime
            # Track trial onset
            if frameN1 == 0: # Count only on the first frame of red fixation
                trial_onset = t2 # relative to triggers
                fix.setColor('red') # set fixation to red
                print('Trial #', trial+1) # for command window
                frameN1 = 1
            fix.draw()
            
        # Image
        if t1 >= redFixTime and t1 <= redFixTime + imgTime:
            img.draw()
            
            # Track stimulus onset and clear RT timer
            if frameN2 == 0: # only on the first frame of Image draw
                stimulus_onset = t2
                studyResp.clearEvents() # clear keyboard
                studyResp.clock.reset()  # Reset timer 
                frameN2 = 1
        
        # Responses, start tracking after red fixation until response cues are available
        if t1 >= redFixTime and t1 <= redFixTime + cueTime:
            curResp = studyResp.getKeys(keyList=['1', '2', '3', '4', '6', '7', '8', '9'], waitRelease=False)
            quit = escapekey.getKeys(keyList=['escape'], waitRelease=False)
            if len(curResp):
                curResp = curResp[0]
                studyResp.keys.append(curResp.name)
                studyResp.rt.append(curResp.rt)
                print('Study Response', curResp.name)
                print('Study Response RT', curResp.rt)

            if len(quit): #an escape button was pressed
                win.close(); 
                core.quit() # terminate 
        # Cues
        if t1 >= redFixTime and t1 <= redFixTime + cueTime:
            cues.draw()

        # White fixation, keep on if null trial
        if t1 >= redFixTime + imgTime:
            if frameN1 == 1: # only on the first frame, to keep logfile readable
                fix.setColor('white')
                frameN1 = 2
            fix.draw()
        
        # Is it time to end the trial or do we flip the window?
        if t1 > redFixTime + imgTime + Jitter:
            runTrial = False
        win.flip()
            
    # Log what happened during the trial
    trial_info = list(curTrial.items()) # for stimlist info
    for col in trial_info:
        a, b = col
        thisExp.addData(a, b)
    thisExp.addData('trial_onset', trial_onset) # Relative to triggers
    thisExp.addData('stimulus_onset', stimulus_onset)
    if studyResp.keys in ['', [], None]:  # No response was made
        studyResp.keys = None
        print('No response!')
    thisExp.addData('response',studyResp.keys)
    if studyResp.keys != None:  
        thisExp.addData('RT', studyResp.rt)
    thisExp.nextEntry()
    
# Finished all trials
text.setText('End of Block')
endTime = globalClock.getTime() + 14
while globalClock.getTime() < endTime:
    bg.draw()
    if globalClock.getTime() < endTime - 2:
        fix.draw()
    else: 
        text.draw()
    win.flip()

win.close()
core.quit()
