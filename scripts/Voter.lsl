// Script to realize votings.
// Note: The voter allows only one vote per avatar.

// Constants:
integer CHANNEL = 1; 
string THANK_YOU_MSG = "Danke für's Abstimmen!";
string FLOAT_TEXT = "Hier für Grün klicken!";
vector COLOR = <0.2, 1.0, 0.2>;

// Local Variables:
integer listen_handle;
list nameList;
integer showVotes;
integer hideFloatText;

updateFloatText()
{
    if (hideFloatText) {
        llSetText("", COLOR, 1.0);
    }
    else { 
        // generate red floating text
        string text = FLOAT_TEXT;
        integer numberOfVotes = llGetListLength(nameList);
        if (showVotes) {
            text +=  "\n" + (string) numberOfVotes + " Stimmen";
        }
        llSetText(text, COLOR, 1.0);
    }
}

integer addVote(key voter)
{
    // Check, if avatar already voted:
    integer votedBefore = 
        ~llListFindList(nameList, [voter]);
    // here: bit-wise NOT (~) 

    if (votedBefore) {
        return FALSE;
    } 
    else {
        nameList += [voter];
        updateFloatText();
        return TRUE;
    }
}

default
{
    on_rez(integer start_param)
    {
        llResetScript();
    }

    state_entry()
    {
        showVotes = TRUE;
        hideFloatText = TRUE;
        updateFloatText();
        
        // Registers the "listener" to the object owner:
        listen_handle = llListen(CHANNEL, "", llGetOwner(), "");
        string text = "Listening to ";
        text += (string) llGetDisplayName(llGetOwner());
        text += " on channel ";
        text += (string ) CHANNEL;
        text += ".";
        llSay(0, text);    
    }

    touch_start(integer num_detected)
    {
        key id = llDetectedKey(0);
        if (addVote(id) && THANK_YOU_MSG != "")
            llInstantMessage(id, THANK_YOU_MSG);
    }
    
    listen(integer channel, string name, key id, string message)
    {
        // received message on specified channel
        
        if (message == "reset") {
            // received "/1 reset" (for CHANNEL = 1) 
            nameList = [];
            updateFloatText();
        }

        if (message == "show") {
            showVotes = TRUE;
            updateFloatText();
        }
        
        if (message == "hide") {
            showVotes = FALSE;
            updateFloatText();
        }

        if (message == "float") {
            hideFloatText = FALSE;
            updateFloatText();
        }

        if (message == "nofloat") {
            hideFloatText = TRUE;
            updateFloatText();
        }

        if (message == "list") {
            integer numberOfVotes = llGetListLength(nameList);              
            if (numberOfVotes == 0) {
                llSay(0, "There are no votes (empty name list).");
            } 
            else {
                llSay(0, "\nVotes:");
                integer i;
                for (i = 0; i < numberOfVotes; i++) {
                    string text = (string) (i + 1);
                    text += ". ";
                    string voter = llList2String(nameList, i);  
                    string avatarLegacyName = llKey2Name(voter);
                    text += (string) llGetDisplayName(voter); 
                    llSay(0, text);
                }
            }   
        }
        
        if (message == "help" || message == "?") {
            llSay(0, "Available commands: reset show hide float nofloat list");
        }
    }
}