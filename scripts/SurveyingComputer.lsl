integer CHANNEL = 5; // change to 0 to deactive channel filter

vector sPos = <0, 0, 0>;
integer initialized = FALSE;
integer listen_handle;
list points = [];
 
string region;
vector regionCorner;
vector hPos; // home position
vector lPos; // local position
vector gPos; // global position
string lPosXStr;
string lPosYStr;
string lPosZStr;
string gPosXStr;
string gPosYStr;
string gPosZStr;
    
default 
{
    state_entry()
    {
        // Store home coordinate:
        hPos = llGetPos();
        llSay(0, "\nHome position: " + (string) hPos);

        // Registers the "listener" to the object owner:
        listen_handle = llListen(CHANNEL, "", llGetOwner(), "");
        llSay(0, "Listening on channel: " + (string) CHANNEL);        
    }

    touch_start(integer total_number)
    {
        region = llGetRegionName();
        regionCorner = llGetRegionCorner(); 
        lPos = llGetLocalPos(); 
        lPosXStr = (string) (lPos.x) + " m";
        lPosYStr = (string) (lPos.y) + " m";
        lPosZStr = (string) (lPos.z) + " m";
        
        gPos = lPos + llGetRegionCorner(); 
        gPosXStr = (string) (gPos.x) + " m";
        gPosYStr = (string) (gPos.y) + " m";
        gPosZStr = (string) (gPos.z) + " m";
    }

    listen(integer channel, string name, key id, string message)
    {
        // received message on specified channel
        
        if (message == "info") {
            // received "/5 info" (for CHANNEL = 5) 
            llSay(0, "\nRegion name: " + region); 
            llSay(0, "Region corner: " + (string) regionCorner); 
        
            llSay(0, "Local prim position:");
            llSay(0, "X: " + lPosXStr); 
            llSay(0, "Y: " + lPosYStr); 
            llSay(0, "Z: " + lPosZStr); 
        
            llSay(0, "Global prim position:");
            llSay(0, "X: " + gPosXStr); 
            llSay(0, "Y: " + gPosYStr); 
            llSay(0, "Z: " + gPosZStr); 
        }
        
        if (message == "save") {
            if (initialized == FALSE || llVecDist(lPos, sPos) > 0.01) {
                sPos = lPos;
                initialized = TRUE;
                points += lPos; // add new item to point list
                llSay(0, "\nSaved local coordinates " + (string) lPos);
                llSay(0, "\nNumber of saved positions: " + (string) llGetListLength(points));
            }
            else {
                llSay(0, "\nIgnored save command (eps filter).");
            }
        }
        
        if (message == "diff") {  
            vector dXY = lPos - sPos;  
            float distXY = llSqrt(dXY.x * dXY.x + dXY.y * dXY.y);
            llSay(0, "\nDistance horiz.: " + (string) distXY);
            llSay(0, "Distance vert: " + (string) (lPos.z - sPos.z));
        }
        
        if (message == "poly") {
            integer nPoints = llGetListLength(points); 
            llSay(0, " ");
             
            if (nPoints == 0) {
                llSay(0, "Pointlist is empty.");
            } 
            else {
                integer i;
                for (i = 0; i < nPoints; i++) {
                    string textline = "Point " + (string) i;
                    textline += ": ";
                    textline += llList2String(points, i);  
                    llSay(0, textline);
                }
            }   
        } 
         
        if (message == "home") {  
            points = [];
            initialized = FALSE;
            llSay(0, "\nCleared memory.");
                     
            vector from = llGetPos();
            float i;
            vector tPos;
            vector delta = hPos - from;
            for (i = 0; i < 1; i = i + 0.05) {
                vector delta = <i * delta.x, i * delta.y, i * delta.z>;
                llSetPos(from + delta);
            } 
            llSetPos(hPos);
            llSay(0, "Brought surveying device back home.");
            llSay(0, "Home position: " + (string) hPos);
        }
        
        if (message == "help") {  
            llSay(0, "\nCommand list: info save diff poly home");
            llSay(0, "Touch device head to capture coordinates.");
        }
    }
}
