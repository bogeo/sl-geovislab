// Invite to join a group, when the the object is touched.
// The recommended group is the group that is set for the object.

vector HIGHLIGHT_COL = <0.9, 0.9, 0.2>;  
vector objectCol;

default
{   
    on_rez(integer start_param)
    {   
        llResetScript();
    }
    
    state_entry()
    {   
        objectCol = llGetColor(ALL_SIDES);
        string text = "\nKlick den Ball an,";
        text += "\num unserer Gruppe";
        text += "\nbeizutreten...";
        llSetText(text, objectCol, 1.0);
    }

    touch_start(integer total_number)
    {   
        list data = llGetObjectDetails(
            llGetKey(), 
            ([OBJECT_GROUP]));
        string groupUUID = llList2String(data, 0);

        llSetColor(HIGHLIGHT_COL, ALL_SIDES);         
        // Note that the instant message below adds a slight delay.
        // Thus the color change will be visible... 
        
        string text = "\nTritt gerne unserer SL-Gruppe bei!";
        text += "Klicke dazu auf den untenstehenden Link:";
        text += "\nsecondlife:///app/group/" + groupUUID + "/about";
        llInstantMessage(llDetectedKey(0), text); 
        
        llSetColor(objectCol, ALL_SIDES);
    }
}