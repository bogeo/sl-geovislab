// Script to realize time estimation polls
// (as known from agile software development projects)

// Constants:
integer CHANNEL = 51; 
vector FLOAT_TEXT_COLOR = <0.2, 1.0, 0.2>;
float FLASH_TALK_TIME = 120.0; // Time given in secs

// Local Variables:
integer phase = 0; // 0 = inactive, 1 = registering phase, 2 = reporting phase
integer listen_handle;
list nameList; 
list valList; 

init() {
    phase = 0;
    hideFloatText();
    nameList = [];
    valList = [];
}

recordEstimation(key participant, float value)
{
    // Note: There's no check, if the avatar has already given an estimation.
    // Thus, every avatar can give more than one estimation. 
    nameList += [participant];
    valList += [value];
}

updateFloatText(string text)
{
    llSetText(text, FLOAT_TEXT_COLOR, 1.0);
}

hideFloatText()
{
    llSetText("", FLOAT_TEXT_COLOR, 1.0);
}

integer minimum()
{
    integer listLen = llGetListLength(valList); 
    if (listLen == 0) {
        return -1;
    }
    float min = (float) llList2String(valList, 0);  
    integer i; 
    integer idx = 0;  
    for (i = 0; i < listLen; i++) {
        float val = (float) llList2String(valList, i);  
        if (val <= min) {
            // Note: Since the last estimation required more time, 
            // we assume that the quality is higher. Thus, here 
            // <= is used instead of <. 
            min = val;
            idx = i;
        }
    }
    return idx;
}

integer maximum()
{
    integer listLen = llGetListLength(valList); 
    if (listLen == 0) {
        return -1;
    }
    float max = (float) llList2String(valList, 0);  
    integer i;
    integer idx = 0;  
    for (i = 0; i < listLen; i++) {
        float val = (float) llList2String(valList, i);  
        if (val >= max) {
            // Note: >= instead of >, see comment above. 
            max = val; 
            idx = i;
        }
    }
    return idx;
}

// String helpers:

string left(string src, string divider) {
    integer index = llSubStringIndex(src, divider);
    if (~index)
        return llDeleteSubString(src, index, -1);
    return src;
}

string right(string src, string divider) {
    integer index = llSubStringIndex(src, divider);
    if (~index)
        return llDeleteSubString(src, 0, index + llStringLength(divider) - 1);
    return src;
}

// Main script:

default
{
    on_rez(integer start_param)
    {
        llResetScript();
        init();
    }

    state_entry()
    {
        // Registers the "listener" to the object owner:
        listen_handle = llListen(CHANNEL, "", llGetOwner(), "");
        string text = "Listening to ";
        text += (string) llGetDisplayName(llGetOwner());
        text += " on channel ";
        text += (string ) CHANNEL;
        text += ".";
        llSay(0, text);
            
        init(); 
    }

    touch_start(integer num_detected)
    {
        if (phase == 0) {
            string str = "Sendet eure Schätzung über Kanal " + (string) CHANNEL + ",";
            str += "\nz. B. \"/" + (string)CHANNEL + " est 0.5\"" + "für einen halben Arbeitstag.";
            llSleep(1.0);
            updateFloatText(str);
            phase = 1;
            return; // !
        }
        
        if (phase == 1) 
        {
            integer numberOfParticipants = llGetListLength(nameList);    
            string text = "Ich habe " + (string) numberOfParticipants;
            text += " Schätzungen erhalten.";
            updateFloatText(text);  
     
            if (numberOfParticipants > 0) {
                llSleep(2.0);
            
                integer minIdx = minimum();
                integer maxIdx = maximum();
            
                string participant;
                string val;
                
                string text = "Minimum: ";
                val = llList2String(valList, minIdx);
                participant = llList2String(nameList, minIdx);  
                text += val + " --> ";   
                text += llGetDisplayName(participant);
                llSay(0, text);

                text = "Maximum: ";
                val = llList2String(valList, maxIdx);
                participant = llList2String(nameList, maxIdx);  
                text += val + " --> ";   
                text += llGetDisplayName(participant);
                llSay(0, text);            

                updateFloatText("Das Resultat habe ich gechattet.");                                     llSleep(5.0);
            }

            init();
        }
    }
    
    listen(integer channel, string name, key id, string message)
    {
        // received message on specified channel

        if (left(message, " ") == "s") {
            float val = (float) right(message, " ");
            recordEstimation(id, val);

            string text = "Prima, dass du dich beteiligst, ";
            text += llGetDisplayName(id) + "!";
            text += "\nIch habe folgende Angabe gespeichert: " + (string) val;
            llInstantMessage(id, text);
            return;
        }
 
        if (message == "help" || message == "?") {
            llSay(0, "Available commands: s help");
        }
    }
}