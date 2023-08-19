// Light control of lecturer speech speed.
// Invisibly for the lecturer, the avatars can click on switches that trigger
// a traffic light display that turns yellow or red if a slower explanation 
// or a repetition is requested. Note that this control consists of four scripts:
// 1. This script to control all the lights (inputs and outputs). And 2. the 
// scripts to control the single lights ("RedLight.lsl", "YellowLight.lsl", 
// "GreenLight.lsl").
 
// Constants:
integer CHANNEL = 42; 

// Local Variables:
integer listen_handle;
integer objState = 0; // 0 = inactive, 1 = green, 2 = yellow, 3 = red

setLight(integer objState) 
{
    if (objState == 0) {
        llSay(CHANNEL, "turn_off_red");
        llSay(CHANNEL, "turn_off_yellow");
        llSay(CHANNEL, "turn_off_green");
        return;
    }

    if (objState == 1) {
        llSay(CHANNEL, "turn_off_red");                   
        llSay(CHANNEL, "turn_off_yellow");
        llSay(CHANNEL, "turn_on_green");
        return;
    }

    if (objState == 2) {
        llSay(CHANNEL, "turn_off_red");                   
        llSay(CHANNEL, "turn_on_yellow");
        llSay(CHANNEL, "turn_off_green");
        return;
    }
    
    if (objState == 3) {
        llSay(CHANNEL, "turn_on_red");
        llSay(CHANNEL, "turn_off_yellow");
        llSay(CHANNEL, "turn_off_green");
        return;
    }
    
    llSay(0, "Something went wrong...");
}


default
{
    state_entry()
    {
        // Registers the "listener":
        listen_handle = llListen(CHANNEL, "", "", "");

        setLight(0);
        objState = 0;
    }

    touch_start(integer num_detected)
    {
        setLight(0);
        objState = 0;
    }
    
    listen(integer channel, string name, key id, string message)
    {
        // received message on specified channel

        integer newState = objState;

        if (message == "report_red") {
            if (objState == 0 || objState == 1) {
                newState = 2;
            } 
            if (objState == 2) {
                newState = 3;    
            } 
            if (objState == 3) {
                newState = 3;    
            } 
        }        

        if (message == "report_yellow") {
            if (objState == 0 || objState == 1 || objState == 2) {
                newState = 2;
            } 
            if (objState == 3) {
                newState = 2;    
            } 
        }        
        
        if (message == "report_green") {
            if (objState == 0 || objState == 1 || objState == 2) {
                newState = 1;
            } 
            if (objState == 3) {
                newState = 2;    
            } 
        }        

        objState = newState;
        setLight(objState);
    }
}
