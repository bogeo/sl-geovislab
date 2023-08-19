// Script to control the yellow light 
// 1. as input element ("report_yellow" message) and 
// 2. as display element ("turn_on_yellow" message).  
// The script "LightController.lsl" holds the control logic of the overall object.

// Constants:
integer CHANNEL = 42; 
vector COLOR_LIGHT_YELLOW = <1, 1, 0>;
vector COLOR_DARK_YELLOW = <0.65, 0.65, 0.45>;

// Local Variables:
integer listen_handle;

lightOn() {
    llSetPrimitiveParams([
        PRIM_COLOR, ALL_SIDES, COLOR_LIGHT_YELLOW, 1.0,
        PRIM_FULLBRIGHT, ALL_SIDES, TRUE,
        PRIM_POINT_LIGHT, TRUE, COLOR_LIGHT_YELLOW, 1.0, 10.0, 0.6, 
        PRIM_GLOW, ALL_SIDES, 0.2]);          
}

lightOff() {
    llSetPrimitiveParams([
        PRIM_COLOR, ALL_SIDES, COLOR_DARK_YELLOW, 1.0,
        PRIM_FULLBRIGHT, ALL_SIDES, TRUE,
        PRIM_POINT_LIGHT, FALSE, COLOR_DARK_YELLOW, 1.0, 10.0, 0.6,
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
        llSay(CHANNEL, "report_yellow");
    }
    
    listen(integer channel, string name, key id, string message)
    {
        // received message on specified channel
        if (message == "turn_on_yellow") {
            // received "/42 turn_on_yellow" (for CHANNEL = 42) 
            lightOn();  
        }        

        // received message on specified channel
        if (message == "turn_off_yellow") {
            lightOff();
        }        
    }
}
