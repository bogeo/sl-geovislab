// Change the texture of a prim "on touch"

// The textures are given as asset UUIDs 
// (e.g., available in the inventory).
string texture1 = "5d10d3aa-0855-9a3e-d57c-ac8eb1a29d34";
string texture2= "e77222f3-9a90-707c-c370-27f634f4f1a8";

integer currentstate; // here, either TRUE or FALSE
integer spin = FALSE; // maybe you might change this setting

switch(string texture)
{
    llSetTexture(texture, ALL_SIDES);
    currentstate = ~currentstate; // switch state
    llSleep(0.0); // sleep time in seconds
    // Since llSetTexture has a short delay, it might be 
    // senseful to add an delay...
}

default
{
    state_entry()
    {
        currentstate = FALSE;
        switch(texture1);
        
        if (spin) {
            // Let the prim spin:
            llTargetOmega(<0,0,1>, 0.2, PI);
        }
    }

    touch_start(integer total_number)
    {
        if (currentstate)
            switch(texture1);
        else
            switch(texture2);
    }
}

