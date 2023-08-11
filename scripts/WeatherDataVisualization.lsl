// This script controls the display of the temperature resp. humidity
// values of the real GeoVisLab as reported by the "weather service". 

//string JSON_PROPERTY = "temperature";
string JSON_PROPERTY = "humidity";
float BAR_LENGTH_MAX = 0.625;
float BAR_POS_Z = 26.917; 
vector FLOAT_TEXT_COLOR = <1.0, 1.0, 0.0>;
float FLOAT_TEXT_OPACITY = 1.0; 

key httpRequestId;
string url; 
float val;
string unit;
vector barColor;
integer showFloatText = FALSE;

// Position [m]:
// X: 74.891
// Y: 96.608
// Z: 26.917
// Size [m]:
// X: 0.010
// Y: 0.025
// Z: 0.625
// Rotation [degrees]:
// X: 0.0
// Y: 0.0
// Z: 0.0

displayResult(float val) 
{
    float percentage = 42;
    unit = "";
    barColor = <0.0, 0.0, 1.0>; // should be a dummy ;-)
    
    if (JSON_PROPERTY == "humidity") {
        percentage = val / 100.0;
        unit = "%";
        if (val < 41.0) {
            barColor = <1.0, 1.0, 0.0>; // yellow
        }
        if (val >= 41.0 && val <= 69.0) {
            barColor = <0.0, 1.0, 0.0>; // green
        }
        if (val > 69.0) {
            barColor = <0.0, 0.5, 1.0>; // blue/cyan
        }
    }
    
    if (JSON_PROPERTY == "temperature") {
        percentage = (val + 10.0) / (40.0 + 10.0); 
        unit = "°C";
        if (val < 18.0) {
            barColor = <0.0, 0.5, 1.0>; // blue/cyan
        }
        if (val >= 18.0 && val < 25.0) {
            barColor = <0.0, 1.0, 0.0>; // green
        }
        if (val >= 69.0) {
            barColor = <1.0, 0.0, 0.0>; // red
        }
    }
    
    if (percentage < 0.0 || percentage > 1.0) {
        llSay(0, "Internal LSL script error!");
        string str = "Details: JSON_PROPERTY = ";
        str += "\"" + JSON_PROPERTY + "\"";
        str += ", val = " + (string) val;
        llSay(0, str);
        return;
    }
    
    reportValueInChat(llRound(val));
    integer reset = TRUE; // for development purposes only
    if (reset == FALSE) {
        // Note: sizeBar(1.0) would reset the bar geometry to 
        // its initial values here.
        sizeBar(1.0);
    }
    else {
        sizeBar(percentage);
    }
    colorBar(percentage);
}

displayFloatText(integer val) 
{
    string str = JSON_PROPERTY + " = ";
    str += ((string) val) + unit;
    llSetText(
        str, 
        FLOAT_TEXT_COLOR, 
        FLOAT_TEXT_OPACITY);   
}
 
hideFloatText() 
{
    llSetText(
        "", 
        FLOAT_TEXT_COLOR, 
        FLOAT_TEXT_OPACITY);
}

reportValueInChat(integer val) 
{
    string str = JSON_PROPERTY + " = ";
    str += ((string) val) + unit;
    llOwnerSay(str);
}

sizeBar(float percentage) 
{
    vector pos = llGetPos();
    vector size = llGetScale();
    llSetScale(<
        size.x, 
        size.y, 
        percentage * BAR_LENGTH_MAX
    >);
    llSay(0, "pre: " + (string) pos);    
    llSetPos(<
        pos.x,
        pos.y,
        BAR_POS_Z - 0.5 * (1.0 - percentage) * BAR_LENGTH_MAX 
    >);
    // Note that llSetPos will not work, if the prim is a child element 
    // inside a group...
}

colorBar(float percentage) {
    llSetColor(barColor, ALL_SIDES);
}
    
default
{
    state_entry()
    {
        llOwnerSay("\nMy key: " + (string) llGetKey());
        if (llGetLinkNumber() > 0) {
            llOwnerSay("Link key: " + (string) llGetLinkKey(llGetLinkNumber()));
        }

        url = "http://193.175.84.40:15000/v2/entities/urn:ngsi-ld:weather:001";
        llSay(0, "Service URL: " + url);
        httpRequestId = llHTTPRequest(
            "http://193.175.84.40:15000/v2/entities/urn:ngsi-ld:weather:001", 
            [ 
                HTTP_METHOD, "GET",
                HTTP_CUSTOM_HEADER, "fiware-service", "hsbokanal",
                HTTP_CUSTOM_HEADER, "fiware-servicepath", "/"
            ],
            "");
        sizeBar(1.0);
    }

    touch_start(integer total_number)
    {
        if (showFloatText == FALSE) {
            showFloatText = TRUE;
            displayFloatText(llRound(val));
        }
        else {
            showFloatText = FALSE;
            hideFloatText();
        }
    }

    http_response(
        key request_id, integer status, list metadata, string body)
    {
        if (request_id != httpRequestId) {
            return; // exit if unknown
        }

        llSay(0, "Received data from service " + url + ".");

        string str; 
        // llSay(0, body);
        string jsonElem = llJsonGetValue(body, [JSON_PROPERTY]);
        // llSay(0, ">" + jsonElem);
        string valStr = llJsonGetValue(jsonElem, ["value"]);
        // llSay(0, ">>" + valStr);
        val = (float) valStr;
        // llSay(0, ">>>" + (string) val);

        displayResult(val);        
    }
}
 