// Implements the survey tool's "field computer"

// Constants:
integer CHANNEL = 5; // change to 0 to deactive channel filter
vector HEAD_COLOR = <0.60, 0.52, 0.13>;
vector FLASH_COLOR = <0.80, 0.80, 0.00>;

// Local Variables:
vector sPos = <0, 0, 0>;
integer initialized = FALSE;
integer listen_handle;
list points = [];
 
string region;
vector regionCorner;
vector lPos; // local position
vector gPos; // global position
string lPosXStr;
string lPosYStr;
string lPosZStr;
string gPosXStr;
string gPosYStr;
string gPosZStr;
    
capture() // capture current object location
{  
    flash();
    
    region = llGetRegionName();
    regionCorner = llGetRegionCorner(); 

    lPos = llGetPos(); 
    lPosXStr = (string) (lPos.x) + " m";
    lPosYStr = (string) (lPos.y) + " m";
    lPosZStr = (string) (lPos.z) + " m";
        
    gPos = lPos + regionCorner; 
    gPosXStr = (string) (gPos.x) + " m";
    gPosYStr = (string) (gPos.y) + " m";
    gPosZStr = (string) (gPos.z) + " m";
}

info() // info output in chat window
{
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

flash() // head flashing (just to improve user experience)
{
    llSleep(0.5);  
    llSetColor(FLASH_COLOR, ALL_SIDES);
    llSleep(1);  
    llSetColor(HEAD_COLOR, ALL_SIDES);
    llSleep(0.25);  
    llSetColor(FLASH_COLOR, ALL_SIDES);
    llSleep(0.5);  
    llSetColor(HEAD_COLOR, ALL_SIDES);
}

default 
{
    state_entry()
    {
        // Set head color:
        llSetColor(HEAD_COLOR, ALL_SIDES);    

        // Registers the "listener" to the object owner:
        listen_handle = llListen(CHANNEL, "", llGetOwner(), "");
        llSay(0, "Listening on channel: " + (string) CHANNEL);    
    }

    touch_start(integer total_number)
    {
        capture();
        info();
    }

    listen(integer channel, string name, key id, string message)
    {
        // received message on specified channel
        
        if (message == "info") {
            // received "/5 info" (for CHANNEL = 5) 
            info();
        }
        
        if (message == "save") {
            capture();
            
            if (initialized == FALSE || llVecDist(lPos, sPos) > 0.01) {
                sPos = lPos;
                initialized = TRUE;
                points += lPos; // add new item to point list
                llSay(0, "\nSaved local coordinates " + (string) lPos);
                integer nPoints = llGetListLength(points);
                llSay(0, "Number of saved positions: " + (string) nPoints);
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
         
        if (message == "export") {  
            integer nPoints = llGetListLength(points); 
            llSay(0, " ");
             
            if (nPoints == 0) {
                llSay(0, "Pointlist is empty.");
            } 
            else {
                integer i;
                llSay(0, "<VRPosExport ver='1.0'>");
                llSay(0, "  <PointSequence>");
                for (i = 0; i < nPoints; i++) {
                    string textline = "    <gml:Point gml:id='";
                    textline += (string) (i + 1);
                    textline += "' srsName='SLglobal'>";
                    llSay(0, textline);
                    textline = "      <gml:pos>";
                    vector point = llList2Vector(points, i);
                    textline += (string) point.x;
                    textline += " ";
                    textline += (string) point.y;
                    textline += " ";
                    textline += (string) point.z;
                    textline += "</gml:pos>";  
                    llSay(0, textline);
                    llSay(0, "    </gml:Point>");
                }
                llSay(0, "  </PointSequence>");
                llSay(0, "</VRPosExport>");
            }   
        }
        
        if (message == "help") {  
            llSay(0, "\nCommand list: info save diff poly export");
            llSay(0, "Touch device head to capture coordinates without storing them.");
        }
    }
}
