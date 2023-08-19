// Script to control the green light 
// 1. as input element ("report_green" message) and 
// 2. as display element ("turn_on_green" message).  
// The script "LightController.lsl" holds the control logic of the overall object.

// Constants:
integer CHANNEL = 42; 
vector COLOR_LIGHT_GREEN = <0, 1, 0>;
vector COLOR_DARK_GREEN = <0.45, 0.65, 0.45>;

// Local Variables:
integer listen_handle;

lightOn() {
    llSetPrimitiveParams([
        PRIM_COLOR, ALL_SIDES, COLOR_LIGHT_GREEN, 1.0,
        PRIM_FULLBRIGHT, ALL_SIDES, TRUE,
        PRIM_POINT_LIGHT, TRUE, COLOR_LIGHT_GREEN, 1.0, 10.0, 0.6, 
        PRIM_GLOW, ALL_SIDES, 0.2]);          
}

lightOff() {
    llSetPrimitiveParams([
        PRIM_COLOR, ALL_SIDES, COLOR_DARK_GREEN, 1.0,
        PRIM_FULLBRIGHT, ALL_SIDES, TRUE,
        PRIM_POINT_LIGHT, FALSE, COLOR_DARK_GREEN, 1.0, 10.0, 0.6,
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
        llSay(CHANNEL, "report_green");
    }
    
    listen(integer channel, string name, key id, string message)
    {
        // received message on specified channel
        if (message == "turn_on_green") {
            // received "/42 turn_on_green" (for CHANNEL = 42) 
            lightOn();  
        }        

        // received message on specified channel
        if (message == "turn_off_green") {
            lightOff();
        }        
    }
}
