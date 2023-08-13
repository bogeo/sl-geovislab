// Script to realize a flash statement round
// (as known from Scrum stand-up meetings)

// Constants:
integer CHANNEL = 50; 
vector FLOAT_TEXT_COLOR = <0.2, 1.0, 0.2>;
float FLASH_TALK_TIME = 60.0; // Time given in secs

// Local Variables:
integer phase = 0; // 0 = inactive, 1 = registering phase, 2 = reporting phase
integer listen_handle;
list nameList; 

init() {
    phase = 0;
    hideFloatText();
    nameList = [];
}

integer registerParticipant(key participant)
{
    // Check, if avatar already voted:
    integer registeredBefore = 
        ~llListFindList(nameList, [participant]);
    // here: bit-wise NOT (~) 

    if (registeredBefore) {
        return FALSE;
    } 
    else {
        nameList += [participant];
        return TRUE;
    }
}

updateFloatText(string text)
{
    llSetText(text, FLOAT_TEXT_COLOR, 1.0);
}

hideFloatText()
{
    llSetText("", FLOAT_TEXT_COLOR, 1.0);
}

default
{
    on_rez(integer start_param)
    {
        llResetScript();
        init();
    }

    state_entry()
    {
        // Registers the "listener" to the object owner:
        listen_handle = llListen(CHANNEL, "", llGetOwner(), "");
        string text = "Listening to ";
        text += (string) llGetDisplayName(llGetOwner());
        text += " on channel ";
        text += (string ) CHANNEL;
        text += ".";
        llSay(0, text);
            
        init(); 
    }

    touch_start(integer num_detected)
    {
        if (phase == 0) {
            string str = "Klickt mich an, um euch anzumelden!";
            llSleep(1.0);
            updateFloatText(str);
            phase = 1;
            return; // !
        }
        
        if (phase == 1) 
        {
            key id = llDetectedKey(0); // avatar id
             
            if (registerParticipant(id)) 
            {
                string msg = "Prima, dass du teilnehmen möchtest, "; 
                msg += llGetDisplayName(id) + "!"; 
                llInstantMessage(id, msg);
                
                integer numberOfParticipants = llGetListLength(nameList);    
                string text = (string) numberOfParticipants + " Anmeldungen";
                updateFloatText(text);    
            }
        }
    }
    
    listen(integer channel, string name, key id, string message)
    {
        // received message on specified channel
        
        if (message == "new") {
            // received "/50 new" (for CHANNEL = 50) 
            nameList = [];
            updateFloatText("Gleich geht's los!");
            phase = 0;
        }

        if (message == "list") {
            integer numberOfParticipants = llGetListLength(nameList);              
            if (numberOfParticipants == 0) {
                llSay(0, "There are no participants (empty name list).");
            } 
            else {
                llSay(0, "\nParticipants:");
                integer i;
                for (i = 0; i < numberOfParticipants; i++) {
                    string text = (string) (i + 1);
                    text += ". ";
                    string participant = llList2String(nameList, i);  
                    text += llGetDisplayName(participant); 
                    llSay(0, text);
                }
            }   
        }
        
        if (message == "begin") {
            integer numberOfParticipants = llGetListLength(nameList);              
            if (numberOfParticipants == 0) {
                string msg = "Leider sind keine Teilnehmer:innen angemeldet.";
                llSay(0, msg);
                updateFloatText(msg);
                llSleep(3.0);
                hideFloatText();
                return;
            } 
            else {
                string text = "Jede(r) Teilnehmer:in hat 120 Sekunden Zeit!"; 
                updateFloatText(text);
                llSleep(5.0);
                updateFloatText("In 5 Sekunden geht es los. ");
                llSleep(5.0);

                integer i;
                for (i = 0; i < numberOfParticipants; i++) {
                    string participant = llList2String(nameList, i);  
                    string text = "Bericht " + (string)(i + 1);
                    text += " von " + (string) numberOfParticipants + ": ";
                    text += llGetDisplayName(participant);
                    updateFloatText(text);
                    llSleep(FLASH_TALK_TIME - 10.0);
                    updateFloatText("Noch 10 Sekunden Redezeit...");
                    llSleep(10.0);
                }
                updateFloatText("Prima, wir sind durch!");
                llSleep(3.0);
                updateFloatText("Tschüss und gerne wieder!");
                llSleep(3.0);
                hideFloatText();
                init();
            }   
        }
        
        if (message == "help" || message == "?") {
            llSay(0, "Available commands: new begin list help");
        }
    }
}