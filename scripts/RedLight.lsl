// Script to control the red light 
// 1. as input element ("report_red" message) and 
// 2. as display element ("turn_on_red" message).  
// The script "LightController.lsl" holds the control logic of the overall object.

// Constants:
integer CHANNEL = 42; 
vector COLOR_LIGHT_RED = <1, 0, 0>;
vector COLOR_DARK_RED = <0.65, 0.45, 0.45>;

// Local Variables:
integer listen_handle;
integer firstTouch = TRUE;

lightOn() {
    llSetPrimitiveParams([
        PRIM_COLOR, ALL_SIDES, COLOR_LIGHT_RED, 1.0,
        PRIM_FULLBRIGHT, ALL_SIDES, TRUE,
        PRIM_POINT_LIGHT, TRUE, COLOR_LIGHT_RED, 1.0, 10.0, 0.6, 
        PRIM_GLOW, ALL_SIDES, 0.1]);          
}

lightOff() {
    llSetPrimitiveParams([
        PRIM_COLOR, ALL_SIDES, COLOR_DARK_RED, 1.0,
        PRIM_FULLBRIGHT, ALL_SIDES, TRUE,
        PRIM_POINT_LIGHT, FALSE, COLOR_DARK_RED, 1.0, 10.0, 0.6,
        PRIM_GLOW, ALL_SIDES, 0.0]);           
}

default
{
    state_entry()
    {
        lightOff(); 

        // Registers the "listener":
        listen_handle = llListen(CHANNEL, "", "", "");
    }

    touch_start(integer total_number)
    {
        if (firstTouch) {
            key av = llDetectedKey(0); // if of avatar that touched the object
            string msg = "Hallo, " + llKey2Name(av) + "!";
            msg += "\nDiese Nachricht siehst nur du.";  
            msg += "\n\nKlicke bei Bedarf ein zweites Mal auf Rot...";
            llInstantMessage(av, msg);
            firstTouch = FALSE;
        }  

        llSay(CHANNEL, "report_red");
    }
    
    listen(integer channel, string name, key id, string message)
    {
        // received message on specified channel
        if (message == "turn_on_red") {
            // received "/42 turn_on_red" (for CHANNEL = 42) 
            lightOn();  
        }        

        // received message on specified channel
        if (message == "turn_off_red") {
            lightOff();
        }        
    }
}
