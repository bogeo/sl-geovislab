// Land information query

default
{
    touch_start(integer total_number)
    {
        // llKey2Name requires the owner avatar to be on sim. 
        // If the owner is absent, no information seems to be available.
        string text = "\nLand owner: ";
        text += llKey2Name(llGetLandOwnerAt(llGetPos()));
        text += ".";
        llSay(0, text);
        
        list details = llGetParcelDetails(llGetPos(), [
            PARCEL_DETAILS_NAME, 
            PARCEL_DETAILS_AREA,
            PARCEL_DETAILS_PRIM_CAPACITY,
            PARCEL_DETAILS_PRIM_USED
            ]);
            
        text = "Local parcel name: " + llList2String(details, 0);
        llSay(0, text);

        text = "Region name: " + llGetRegionName();
        llSay(0, text); 

        text = "Parcel area: " + llList2String(details, 1);
        text += "sqm";
        llSay(0, text);
        
        text = "Current prim-usage: ";
        text += llList2String(details, 3);
        text += " of max. ";
        text += llList2String(details, 2);
        text += " prims used.";
        llSay(0, text);
        
        vector gpos;
        vector regionCorner = llGetRegionCorner(); 
        vector gPos = llGetPos() + regionCorner; 
        string gPosXStr = (string) (gPos.x) + "m";
        string gPosYStr = (string) (gPos.y) + "m";
        string gPosZStr = (string) (gPos.z) + "m";
        text = "Global coordinate for query position:";
        llSay(0, text);
        llSay(0, "X: " + gPosXStr); 
        llSay(0, "Y: " + gPosYStr); 
        llSay(0, "Z: " + gPosZStr); 
    }
}